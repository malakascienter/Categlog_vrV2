# DBProject – SQL Server database as code

The database lives in Git as a **SQL Server Database Project** (`AppDb.sqlproj`).
Each table, view, procedure and function is **one file** showing its full current definition.
Nobody writes `ALTER` scripts by hand: SqlPackage compares the project with a database
and generates the change script automatically.

```
DBProject.sln
AppDb/
  AppDb.sqlproj              SDK-style project (picks up every .sql file automatically)
  AppDb.refactorlog          rename history - always commit it
  dbo/Tables|Views|StoredProcedures|Functions/   one file per object
  app/                       version tracking (app.DbVersion, app.vw_CurrentVersion)
  Security/Roles/            database roles
  Scripts/
    Script.PreDeployment.sql   runs before schema changes
    Script.PostDeployment.sql  runs after: lookup data, dev sample data, version record
    PostDeploy/*.sql
  PublishProfiles/           Local / Dev / Test / Prod settings
scripts/                     PowerShell helpers
pipelines/azure-pipelines.yml   Azure DevOps CI/CD
.github/workflows/db-ci.yml     GitHub Actions CI (use one of the two)
```

---

## 1. One-time setup (each developer, Windows)

1. **Visual Studio 2022 (17.14+) or newer**, with the workload **Data storage and processing**.
   In the Visual Studio Installer, under *Individual components*, also tick
   **SQL Server Data Tools, SDK-style**.
2. **.NET 8 SDK or newer** (usually installed with Visual Studio).
3. **SqlPackage** (PowerShell):
   ```powershell
   dotnet tool install -g microsoft.sqlpackage
   ```
4. **LocalDB** comes with Visual Studio. Check it works:
   ```powershell
   sqllocaldb info MSSQLLocalDB
   ```
   (If you prefer SQL Server Developer Edition, copy `Local.publish.xml` to
   `Local.mine.publish.xml` and change `Data Source` to `localhost`. The `*.mine.*` files are git-ignored.)
5. Clone and create your local database:
   ```powershell
   git clone <repo-url>
   cd DBProject
   .\scripts\Publish-Local.ps1
   ```
   You now have `AppDb` on `(localdb)\MSSQLLocalDB` with sample data.

> If PowerShell blocks the scripts, run once:
> `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

---

## 2. Import an existing database (server + login + password)

Use this once to load your real database into the project. It replaces the sample
`dbo` objects with everything from your database.

```powershell
# SQL login - the password is asked securely, never stored
.\scripts\Import-Database.ps1 -Server "192.168.1.50" -Database "ShopDb" -User "sa"

# Named instance / custom port
.\scripts\Import-Database.ps1 -Server "MYPC\SQLEXPRESS" -Database "ShopDb" -User "dev"
.\scripts\Import-Database.ps1 -Server "myserver,1433"    -Database "ShopDb" -User "dev"

# Only the dbo schema
.\scripts\Import-Database.ps1 -Server "192.168.1.50" -Database "ShopDb" -User "sa" -OnlyDbo

# Also import users, roles and GRANT/DENY permissions (skipped by default)
.\scripts\Import-Database.ps1 -Server "192.168.1.50" -Database "ShopDb" -User "sa" -IncludeSecurity

# Windows login instead of password
.\scripts\Import-Database.ps1 -Server "localhost" -Database "ShopDb" -WindowsAuth
```

It creates one file per object (`dbo\Tables\Customer.sql`, `dbo\StoredProcedures\...`).
`Scripts\`, `PublishProfiles\` and `app\` are never touched.

**After importing:**
1. Build (Ctrl+Shift+B) and fix any errors. These are usually old procedures that reference
   columns that no longer exist, which the old system never caught.
2. Edit `Scripts\PostDeploy\LookupData.sql` and `DevSampleData.sql` so they use your real
   tables. The sample ones refer to `Roles`, `Users`, `Products`...
3. Remove `Security\Roles\AppReader.sql` / `AppWriter.sql` if you don't want those roles.
4. Commit.

**Same thing in Visual Studio (no script):** right-click the project → **Import → Database...**
→ *Select Connection* → enter the server, choose **SQL Server Authentication**, type the login and
password → pick the database → *Folder structure: Schema\Object Type* → **Start**.

**To pull later changes made directly on a server:** *Tools → SQL Server → New Schema Comparison*,
with the server as **Source** and the project as **Target**, then **Update**.

---

## 3. Daily workflow

```
git pull
.\scripts\Publish-Local.ps1          # your DB now matches main

git checkout -b feature/add-customer-phone
# edit dbo\Tables\Customer.sql  -> add the column line
# update any procedure / view that should use it
# Build (Ctrl+Shift+B)           -> errors if something references a missing column
.\scripts\Publish-Local.ps1          # applies the change to your local DB
# test your app

git add . ; git commit -m "Add Phone to Customer" ; git push
# open a Pull Request -> CI builds the dacpac -> review -> merge
```

You can also publish from Visual Studio: right-click **AppDb → Publish → Load Profile →
`PublishProfiles\Local.publish.xml` → Publish**.

Local DB broken or messy? `.\scripts\Reset-Local.ps1` drops it and rebuilds it.

---

## 4. Rules

| Rule | Why |
|---|---|
| Change objects only in the project files, never directly on Dev/Test/Prod | Otherwise the server drifts from Git |
| **Rename** tables/columns with right-click **Refactor → Rename** | Writes to `AppDb.refactorlog`. Without it, a rename becomes *drop + create* and **data is lost** |
| Data changes go in `Scripts\PostDeploy\*.sql` and must be re-runnable (`MERGE`, `IF NOT EXISTS`) | Post-deploy runs on **every** publish |
| No `GO` inside `DevSampleData.sql` | It is included inside an `IF ... BEGIN END` block |
| One object per file, file name = object name | Clean diffs, fewer conflicts |
| Hard changes (change a column type that has data, split a table) take 2 releases | Release 1: add new column + copy data in post-deploy. Release 2: drop old column |
| Always commit `AppDb.refactorlog` | Every DB needs the same rename history |

### Merge conflicts
- Two people add different tables → **no conflict** (different files, and the `.sqlproj` doesn't list files).
- Two people add different columns to the same table → Git usually merges it automatically.
- Real conflict in a table file → resolve it like C# code, then **Build**. The build tells you if the result is valid.
- Conflict in `AppDb.refactorlog` → keep **both** `<Operation>` entries.

---

## 5. Versions and releases

1. Set `<DacVersion>` in `AppDb.sqlproj` (e.g. `1.2.0`).
2. Merge to `main`, then tag: `git tag v1.2.0 ; git push --tags`.
3. The pipeline builds `AppDb.dacpac` (the release artifact), deploys to Test, then Prod after approval.
4. Each publish writes a row to `app.DbVersion`. To check any database:
   ```sql
   SELECT * FROM app.vw_CurrentVersion;
   ```

### Before a Prod release: review the script
```powershell
.\scripts\New-DeployScript.ps1 -Environment Prod -Server "prod-sql01" -User "deploy"
```
This creates `deploy-output\AppDb_Prod_<date>.sql` and a change report **without running anything**.
The Prod profile also blocks data loss, backs up the database first, and never drops objects
that are not in the project.

---

## 6. Environments

| Profile | Server | Drops extra objects | Blocks data loss | Sample data |
|---|---|---|---|---|
| Local | `(localdb)\MSSQLLocalDB` | yes | no | yes |
| Dev | from pipeline variable | yes | yes | yes |
| Test | from pipeline variable | yes | yes | no |
| Prod | from pipeline variable | **no** | yes + backup | no |

Connection strings and passwords for Dev/Test/Prod are **never stored in Git**. Put them in
pipeline secret variables (`TestDbConnection`, `ProdDbConnection`).

---

## 7. Troubleshooting

| Problem | Fix |
|---|---|
| Visual Studio can't load `AppDb.sqlproj` | Install the **SQL Server Data Tools, SDK-style** component (step 1). Or open the folder in VS Code with the *SQL Database Projects* extension |
| `sqlpackage not found` | `dotnet tool install -g microsoft.sqlpackage`, then reopen PowerShell |
| Publish says *data loss might occur* | Expected on Test/Prod. Rewrite the change in 2 steps (see Rules) |
| Build error `SQL71501: unresolved reference` | A view/procedure uses an object or column that doesn't exist. Fix the reference |
| Import fails with a login error | Check the server name/port, that SQL authentication is enabled, and that the login has `VIEW DEFINITION` on the database |
