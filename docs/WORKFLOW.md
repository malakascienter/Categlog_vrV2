# Database Version Control – Full Workflow and Scenarios

One database (`AppDb`) is used by several software modules. Each module is released on its own
schedule, so each one may run a different version against the same database. This document
explains how schema changes, settings data and one-time data changes move consistently from
every developer's PC to Test and Production, and how database versions are tied to software
versions.

> **Status legend**
> - **[EXISTS]** already in this repository today
> - **[PLANNED]** designed here, not implemented yet

---

## Table of contents

1. [Core ideas](#1-core-ideas)
2. [The big picture](#2-the-big-picture)
3. [Repository layout](#3-repository-layout)
4. [The three kinds of change](#4-the-three-kinds-of-change)
5. [What happens inside every publish](#5-what-happens-inside-every-publish)
6. [Versioning model (DB version vs module versions)](#6-versioning-model)
7. [One-time setup](#7-one-time-setup)
8. [Daily developer workflow](#8-daily-developer-workflow)
9. [Scenarios](#9-scenarios)
10. [Pull request and CI checks](#10-pull-request-and-ci-checks)
11. [Release process](#11-release-process)
12. [Rollback and recovery](#12-rollback-and-recovery)
13. [Rules](#13-rules)
14. [Troubleshooting](#14-troubleshooting)
15. [Implementation checklist](#15-implementation-checklist)

---

## 1. Core ideas

1. **Git is the single source of truth.** No one edits Test or Prod by hand.
2. **Schema is declarative.** Each object is one `.sql` file with its full current definition.
   SqlPackage compares the project to a database and generates the `ALTER` script. [EXISTS]
3. **Settings and reference data are re-runnable.** They are `MERGE` scripts that run on every
   publish, so every database converges to what Git says. [EXISTS for lookups, PLANNED for settings]
4. **One-time data changes are tracked.** Backfills and conversions run once per database and are
   recorded in a history table. [PLANNED]
5. **The database is backward compatible.** The database is always at least as new as the newest
   module, and it still works with every supported older module version. Breaking changes are
   done in several releases (expand, then contract). [PLANNED]
6. **Each module declares which database versions it works with**, and a deploy is blocked if
   the database is outside that range. [PLANNED]

---

## 2. The big picture

```
                         GIT REPOSITORY  (single source of truth)
 ┌─────────────────────────────────────────────────────────────────────────┐
 │  schema files   settings files   lookups   migrations   release notes   │
 └──────────────────────────────────┬──────────────────────────────────────┘
                                    │  build
                                    ▼
                              AppDb.dacpac   (one per DB version, kept forever)
                                    │
        ┌───────────────┬───────────┴───────────┬────────────────┐
        ▼               ▼                       ▼                ▼
   Dev PC (Local)      Dev server              Test             Prod
   Publish-Local       auto on merge           auto on merge    on tag + approval
                                                                 (script reviewed first)

                       ONE DATABASE  (AppDb)  ── DB version 1.8.0
        ┌───────────────────────────────────────────────────────┐
        │ core.*   (shared)   sales.*    inventory.*    hr.*    │
        └───────▲───────────────▲───────────▲─────────────▲─────┘
                │               │           │             │
          Module Sales    Module Inventory   Module HR   Module Web
          v2.3  needs     v1.5 needs         v4.0 needs  v3.1 needs
          DB >= 1.6       DB >= 1.4          DB >= 1.8   DB >= 1.7

   Compatibility rule:  Module.MinDbVersion <= DB version <= Module.MaxDbVersion
```

### How a change travels

```
 DEVELOPER A                       GIT                        ENVIRONMENTS
 ───────────                  ───────────                  ─────────────────
 edit table/proc .sql  ─┐
 edit Settings file    ─┼─► commit ─► Pull Request ─► CI
 New-Migration script  ─┘                              │ 1 build dacpac
                                                       │ 2 old migrations unchanged?
 DEVELOPER B  ◄── git pull ◄── merge to main ◄─────────┤ 3 breaking-change check
 Publish-Local.ps1                                     │ 4 deploy twice on scratch DB
 (gets A's changes)                                    ▼
                                           main ──► auto deploy ──► TEST
                                           tag db-v1.x ─► script + review
                                                       ─► approval ──► PROD
```

---

## 3. Repository layout

```
DBProject.sln
AppDb/
  AppDb.sqlproj                  SDK-style project; every .sql file is picked up automatically [EXISTS]
  AppDb.refactorlog              rename history, always commit [EXISTS, file name needs fixing]
  dbo/ or <module>/
     Tables|Views|StoredProcedures|Functions/   one file per object [EXISTS for dbo]
  app/                           version tracking
     Tables/DbVersion.sql                 [EXISTS]
     Tables/Settings.sql                  [PLANNED]
     Tables/MigrationHistory.sql          [PLANNED]
     Tables/ModuleVersion.sql             [PLANNED]
     Tables/ModuleCompatibility.sql       [PLANNED]
     StoredProcedures/usp_AssertCompatible.sql   [PLANNED]
  Security/Roles/
  Scripts/
     Script.PreDeployment.sql             [EXISTS]
     Script.PostDeployment.sql            [EXISTS]
     PostDeploy/
        Lookups/*.sql                     one MERGE file per lookup table [PLANNED split]
        Settings/Settings.All.sql         settings for every environment [PLANNED]
        Settings/Settings.Local|Dev|Test|Prod.sql   per-environment values [PLANNED]
        Migrations.sql                    register of run-once scripts [PLANNED]
        Compatibility.sql                 loads app.ModuleCompatibility from Git [PLANNED]
        DevSampleData.sql                 Local/Dev only [EXISTS]
        RecordVersion.sql                 [EXISTS]
     Migrations/2026MMDD_NN_Name.sql      one-time data changes [PLANNED]
  PublishProfiles/ Local | Dev | Test | Prod .publish.xml   [EXISTS]
  Releases/1.8.0.md                       release notes per DB version [PLANNED]
  Compatibility/modules.json              module version <-> DB version ranges [PLANNED]
scripts/
  Publish-Local.ps1  Reset-Local.ps1  New-DeployScript.ps1  Import-Database.ps1   [EXISTS]
  New-Migration.ps1  Export-Settings.ps1  Compare-Environment.ps1                  [PLANNED]
  Test-BreakingChanges.ps1  Test-Migrations.ps1                                    [PLANNED]
.github/workflows/db-ci.yml               [EXISTS, Prod stage PLANNED]
pipelines/azure-pipelines.yml             [EXISTS] (use one of the two)
docs/WORKFLOW.md                          this file
```

---

## 4. The three kinds of change

| Kind | Examples | Where it lives | How it moves | Runs |
|---|---|---|---|---|
| **Schema** | table, column, index, view, procedure, function | `dbo/...` or `<module>/...` one file per object | SqlPackage generates `ALTER` from the diff | on every publish (only changes are applied) |
| **Settings and reference data** | feature flags, tax rate, status names, role list | `Scripts/PostDeploy/Settings/*.sql`, `Lookups/*.sql` | `MERGE` makes the table match Git | on every publish |
| **One-time data change** | backfill a new column, split a name, convert values | `Scripts/Migrations/*.sql` | run once, then recorded in `app.MigrationHistory` | once per database |

### Settings table [PLANNED]

```sql
CREATE TABLE [app].[Settings]
(
    [SettingKey]   NVARCHAR (200)  NOT NULL,   -- e.g. 'Sales:TaxRate' (module prefix)
    [SettingValue] NVARCHAR (2000) NULL,
    [Description]  NVARCHAR (500)  NULL,
    CONSTRAINT [PK_Settings] PRIMARY KEY CLUSTERED ([SettingKey])
);
```

Settings are loaded in two layers: `Settings.All.sql`, then `Settings.<Environment>.sql`
which overrides values for that environment only. A key removed from Git is removed from
every database (`WHEN NOT MATCHED BY SOURCE THEN DELETE`).

> **Secrets** (passwords, API keys) never go in Git. Store them in pipeline secrets or a vault
> and let each environment supply them.

### Migration history table [PLANNED]

```sql
CREATE TABLE [app].[MigrationHistory]
(
    [MigrationId] NVARCHAR (100) NOT NULL,     -- file name without .sql
    [DbVersion]   NVARCHAR (20)  NOT NULL,     -- release that introduced it
    [AppliedAt]   DATETIME2 (0)  NOT NULL DEFAULT (SYSUTCDATETIME()),
    [AppliedBy]   NVARCHAR (128) NOT NULL DEFAULT (SUSER_SNAME()),
    CONSTRAINT [PK_MigrationHistory] PRIMARY KEY CLUSTERED ([MigrationId])
);
```

Each migration file is wrapped so it runs once:

```sql
IF NOT EXISTS (SELECT 1 FROM [app].[MigrationHistory] WHERE [MigrationId] = N'20261120_01_BackfillOrderTotals')
BEGIN
    -- your SQL here (no GO)
    INSERT INTO [app].[MigrationHistory] ([MigrationId], [DbVersion])
    VALUES (N'20261120_01_BackfillOrderTotals', N'$(DacVersion)');
END;
```

`New-Migration.ps1` creates this file and appends its `:r` line to `PostDeploy/Migrations.sql`.
That register file uses `merge=union` in `.gitattributes`, so two developers adding migrations
at the same time do not conflict.

---

## 5. What happens inside every publish

The order is the same on every PC and environment.

```
 AppDb.dacpac + publish profile (Local / Dev / Test / Prod)
        │
        ▼
 1. Pre-deployment script      back up data that a risky change would lose
 2. Schema compare             generates ALTER script, uses refactorlog for renames
 3. Post-deployment script
       a. Lookups               MERGE reference rows
       b. Settings              MERGE settings (All, then environment file)
       c. Migrations            run each NEW migration once, record it
       d. Compatibility         load module version ranges from Git
       e. Dev sample data       Local and Dev only
       f. RecordVersion         row in app.DbVersion
```

Everything in step 3 must be safe to run many times.

---

## 6. Versioning model

### Two version numbers

| Version | Example | Where it is set | Meaning |
|---|---|---|---|
| **DB version** | `1.8.0` | `<DacVersion>` in `AppDb.sqlproj`, git tag `db-v1.8.0` | the state of the database release |
| **Module version** | `Sales 2.3.0` | each module's own repo, tag `sales-v2.3.0` | one software release |

Use semantic meaning for the DB version:
- **MAJOR**: a breaking change was completed (an old object was dropped)
- **MINOR**: additive change (new column, table, procedure, setting)
- **PATCH**: fix with no schema change (data or procedure body fix)

### Tables [PLANNED]

| Table | Purpose |
|---|---|
| `app.DbVersion` | every DB release deployed, where, when, by whom [EXISTS] |
| `app.ModuleVersion` | module version currently installed per environment |
| `app.ModuleCompatibility` | per module version, the minimum and maximum DB version it works with |
| `app.MigrationHistory` | run-once scripts already applied |

### Compatibility file in Git

```json
{
  "Sales":     { "2.3.0": { "minDb": "1.6.0", "maxDb": "1.9.99" },
                 "2.2.0": { "minDb": "1.4.0", "maxDb": "1.7.99" } },
  "Inventory": { "1.5.0": { "minDb": "1.4.0", "maxDb": "1.9.99" } },
  "HR":        { "4.0.0": { "minDb": "1.8.0", "maxDb": "1.9.99" } }
}
```

### The check

```sql
EXEC app.usp_AssertCompatible @Module = 'Sales', @ModuleVersion = '2.3.0';
-- raises an error if the current DB version is outside [minDb, maxDb]
```

Run it:
- in each **module's deploy pipeline**, before deploying the module
- optionally at **module startup**, so an app refuses to run on an incompatible database

After a successful module deploy, the pipeline records the module in `app.ModuleVersion`.

### Ownership

Give every module its own schema (`sales`, `inventory`, `hr`), plus `core` (or `dbo`) for
shared objects. A change to a shared object needs approval from every module that uses it.
Setting keys carry a module prefix (`Sales:TaxRate`).

---

## 7. One-time setup

### Project owner

1. Fix the tooling on the build machine. `sqlpackage` needs .NET 10.0.11 (this PC has 10.0.10),
   or reinstall `sqlpackage` for .NET 8.
2. `git init`, commit everything, push to the remote (GitHub or Azure DevOps).
3. Rename `AppDb.refactorlog.xml` to `AppDb.refactorlog` so the project picks it up.
4. Implement the planned items in [section 15](#15-implementation-checklist).
5. Create CI environments `test` and `prod`. Add an approval rule on `prod`. Add secrets
   `TEST_DB_CONNECTION` and `PROD_DB_CONNECTION`.
6. Import the real database once:
   ```powershell
   .\scripts\Import-Database.ps1 -Server "myserver" -Database "ShopDb" -User "sa"
   ```
   Then build, fix `SQL71501` errors, and move real settings into the Settings files.
7. Decide module ownership and create the schemas. Fill `Compatibility/modules.json` for the
   module versions currently in production.
8. Protect `main`: pull requests only, CI must pass, at least one reviewer.

### Each developer

1. Install Visual Studio 2022 17.14+ with *Data storage and processing* and
   *SQL Server Data Tools, SDK-style*.
2. Install the .NET SDK and `dotnet tool install -g microsoft.sqlpackage`.
3. Check LocalDB: `sqllocaldb info MSSQLLocalDB`.
4. `git clone <repo>`, `cd DBProject`, `.\scripts\Publish-Local.ps1`.

---

## 8. Daily developer workflow

```
git pull
.\scripts\Publish-Local.ps1             # your DB now matches main

git checkout -b feature/short-name

# make the change that fits (see section 9):
#   schema       -> edit the object's .sql file
#   setting      -> edit Settings.All.sql or Settings.<Env>.sql
#   lookup rows  -> edit the file in PostDeploy\Lookups
#   data convert -> .\scripts\New-Migration.ps1 -Name "WhatItDoes"

# Build (Ctrl+Shift+B)                  # fails if something references a missing object
.\scripts\Publish-Local.ps1             # apply to your local DB
# test your module

git add . ; git commit -m "..." ; git push
# open a Pull Request -> CI -> review -> merge
```

---

## 9. Scenarios

### Scenario 1. Add a nullable column (safe, additive)

1. Edit `dbo/Tables/Customers.sql`, add the line `[Phone] NVARCHAR(30) NULL,`.
2. Update views or procedures that should return it.
3. Build, `Publish-Local.ps1`, test.
4. Commit. Old modules keep working because they never select the new column.
5. Release note: `Releases/1.8.0.md` lists the column and the modules that may use it.

### Scenario 2. Add a NOT NULL column to a table with data

SqlPackage cannot add a NOT NULL column without a default to a table that has rows.

1. Add the column with a **default constraint**:
   `[Currency] NCHAR(3) NOT NULL CONSTRAINT [DF_Orders_Currency] DEFAULT ('USD')`.
2. If existing rows need different values, add a migration to set them:
   `.\scripts\New-Migration.ps1 -Name "SetOrderCurrency"`.
3. Publish locally, check, commit.

### Scenario 3. Rename a column or table

A rename done by editing the text becomes drop + create, which **loses data**.

1. In Visual Studio: right-click the column, **Refactor → Rename**. This writes to
   `AppDb.refactorlog`.
2. Commit the refactorlog together with the changed files.
3. Because old modules still use the old name, treat this as a **breaking change** and use
   scenario 5 (expand and contract) if any supported module uses it.

### Scenario 4. Change a setting for all environments

1. Edit `Scripts/PostDeploy/Settings/Settings.All.sql`:
   ```sql
   ('Sales:MaxDiscountPercent', N'15', N'Largest discount a clerk may give')
   ```
2. `Publish-Local.ps1`, test, commit, merge.
3. Test and Prod receive the new value in their next deploy.

### Scenario 5. Breaking change using expand and contract (rename or drop)

Example: rename `Customers.Phone` to `Customers.MobilePhone` while Sales 2.2 still uses `Phone`.

| Step | DB version | Action | Old module affected? |
|---|---|---|---|
| 1. Expand | 1.7.0 | Add `MobilePhone`. Migration copies `Phone` into it. Add a trigger or computed column to keep both in sync, or have the procedure write both. | No |
| 2. Migrate | modules | Each module releases a version that uses `MobilePhone`. Update `modules.json` ranges. | No |
| 3. Contract | 1.9.0 | When no supported module version uses `Phone`, drop it. Mark `minDb` for all supported module versions accordingly. | No, because none depend on it |

CI's breaking-change check (section 10) refuses step 3 until `modules.json` shows no supported
module version needs the old object.

### Scenario 6. One-time data conversion

Split `FullName` into `FirstName` and `LastName`.

1. Add the two new nullable columns (schema file change).
2. `.\scripts\New-Migration.ps1 -Name "SplitCustomerName"` and write the `UPDATE`.
3. Publish locally. Run it twice, and the second run must do nothing.
4. Never edit the migration after it has been merged. If it was wrong, add a new migration.

### Scenario 7. Change data that only one environment should have

Prod needs a different payment gateway URL than Test.

1. Put the default in `Settings.All.sql`.
2. Put the override in `Settings.Prod.sql`.
3. Only Prod gets the override value. Keep passwords out and supply them from the pipeline.

### Scenario 8. A change to a shared object used by several modules

1. Find the objects' consumers (`Releases/` notes and module ownership list).
2. Open the pull request and require approval from each affected module owner.
3. Make the change additive if possible (new column, new overload) so no module has to
   change at the same time.
4. List affected modules in the release note.

### Scenario 9. A new module joins the database

1. Create its schema: `AppDb/hr/hr.sql` with `CREATE SCHEMA [hr];`.
2. Add its tables, procedures and roles under `AppDb/hr/...`.
3. Add its setting keys with the prefix (`HR:...`).
4. Add its version ranges to `Compatibility/modules.json`.
5. Add the compatibility check step to the module's deploy pipeline.

### Scenario 10. Two developers change the same table

- Different columns: Git usually merges automatically.
- Same lines: resolve like code, then **Build**. The build proves the result is valid.
- Conflict in `AppDb.refactorlog`: keep **both** `<Operation>` entries.
- Conflict in `Migrations.sql`: the `merge=union` rule keeps both lines.
  Two migrations with the same number are fine; the date and name make each one unique.

### Scenario 11. Someone changed Test or Prod directly (drift)

1. `.\scripts\Compare-Environment.ps1 -Environment Test` reports the difference. [PLANNED]
2. Decide for each difference:
   - **Keep it**: bring it into Git. For settings run `Export-Settings.ps1`, for schema use
     Visual Studio Schema Compare (database as source, project as target).
   - **Discard it**: the next deploy overwrites it. Prod blocks the deploy first
     (`BlockWhenDriftDetected`), so nothing is lost silently.
3. Remind the team of the rule: no direct changes.

### Scenario 12. Hotfix on Prod

1. Branch from the **last released tag**, not from `main`:
   `git checkout -b hotfix/1.8.1 db-v1.8.0`.
2. Make the smallest fix. A patch version with no destructive change.
3. PR into a release branch, tag `db-v1.8.1`, deploy through the normal Prod approval.
4. Merge the same fix into `main` so it is not lost.

### Scenario 13. Release a module that needs a newer database

1. The DB release goes first (additive, backward compatible), tagged `db-v1.8.0`, deployed.
2. The module's pipeline runs `usp_AssertCompatible`. If the database is too old, the deploy
   stops with a clear message.
3. The module deploys and records itself in `app.ModuleVersion`.

### Scenario 14. Roll back a module

1. Redeploy the previous module version.
2. This works because the database is still backward compatible with it. No database rollback.
3. If the previous module version needs a **lower** database version than the current one,
   that means the database change was not backward compatible. Fix it with a forward
   patch release.

### Scenario 15. A bad database release

1. Do not edit the released scripts.
2. Create a patch release (`1.8.1`) that corrects the problem, and deploy it.
3. Data corruption only: restore the pre-deploy backup (Prod profile backs up automatically)
   and re-deploy the fixed version.

### Scenario 16. Import an existing database

Done once at the start (see [section 7](#7-one-time-setup)). Later changes made directly on a
server should come back through Schema Compare, then be committed.

### Scenario 17. New developer joins

Follow "Each developer" in section 7. In about 15 minutes they have a working local database.

### Scenario 18. Reset a broken local database

```powershell
.\scripts\Reset-Local.ps1
```

---

## 10. Pull request and CI checks

| # | Check | Fails when |
|---|---|---|
| 1 | Build the dacpac | any `SQL71501` unresolved reference or warning (warnings are errors) |
| 2 | Migration immutability | a migration file that exists on `main` was modified or deleted |
| 3 | Migration register | a migration file is not listed in `Migrations.sql` |
| 4 | Breaking-change detection | the new dacpac drops or changes a column, table or procedure that the previous release had, and `modules.json` still lists a supported module version that needs it |
| 5 | Idempotency | publish to a scratch database twice, and the second publish changes anything |
| 6 | Compatibility file | `modules.json` is invalid or a module has no version covering the new DB version |
| 7 | Release note | `DacVersion` changed but `Releases/<version>.md` does not exist |

Checks 4 and 5 are the most important. They prove that a change is safe for older modules and
that deploying twice gives the same result.

---

## 11. Release process

### Database release

1. Set `<DacVersion>` in `AppDb.sqlproj` (for example `1.8.0`).
2. Add `Releases/1.8.0.md` (what changed, affected modules, breaking or not).
3. Update `Compatibility/modules.json` if new module versions are supported.
4. Merge to `main`. CI deploys **Test** automatically.
5. Verify on Test: `SELECT * FROM app.vw_CurrentVersion;` and run the module test suites.
6. Tag: `git tag db-v1.8.0 ; git push --tags`.
7. The pipeline generates the Prod change script and attaches it as an artifact.
8. A reviewer reads the script and approves the `prod` environment.
9. The pipeline publishes to Prod (data loss blocked, backup first, no drops outside the project).
10. The dacpac is kept as a release artifact for every version, so any version can be rebuilt.

### Module release

1. The module team sets its own version and tag.
2. The module pipeline calls `usp_AssertCompatible`.
3. It deploys the module and writes `app.ModuleVersion`.

### Preview a Prod release locally

```powershell
.\scripts\New-DeployScript.ps1 -Environment Prod -Server "prod-sql01" -User "deploy"
```

Creates `deploy-output\AppDb_Prod_<date>.sql` and a change report without running anything.

---

## 12. Rollback and recovery

| Problem | Response |
|---|---|
| Module bug | Redeploy the previous module version. The database stays. |
| Bad DB release | Forward fix as a patch release. Never edit released files. |
| Data corruption | Restore the pre-deploy backup, then redeploy the corrected version. |
| Migration failed half-way | Migrations run inside the publish transaction (`IncludeTransactionalScripts`), so a failure rolls back and the next publish retries. Check the failure and fix it with a new migration only if it was already recorded. |
| Wrong setting value | Fix the file and merge. Every environment converges at the next deploy. |

---

## 13. Rules

| Rule | Why |
|---|---|
| Change objects only in project files, never directly on Dev/Test/Prod | Otherwise the server drifts from Git |
| Rename with **Refactor → Rename**, and commit the refactorlog | A text rename becomes drop + create and loses data |
| Post-deploy scripts must be re-runnable (`MERGE`, `IF NOT EXISTS`) | They run on every publish |
| No `GO` in post-deploy or migration files | They are included inside blocks |
| Applied migrations are never edited | Databases that already ran them would differ |
| Breaking changes take 2 or 3 releases (expand, migrate, contract) | Older modules stay working |
| No drop or rename until `modules.json` shows no supported module needs it | Compatibility guarantee |
| One object per file, file name = object name | Clean diffs, fewer conflicts |
| Shared object changes need approval from each consuming module | Prevent surprise breaks |
| Secrets never in Git | Security |
| Every DB release has a release note listing affected modules | Traceability |
| Always commit `AppDb.refactorlog` | Every database needs the same rename history |

---

## 14. Troubleshooting

| Problem | Fix |
|---|---|
| `sqlpackage` fails with a .NET framework error | Install the .NET version it asks for, or reinstall `sqlpackage` for a .NET you have |
| Visual Studio cannot load `AppDb.sqlproj` | Install *SQL Server Data Tools, SDK-style* |
| Build error `SQL71501` | A view or procedure references something that does not exist. Fix the reference |
| Publish says *data loss might occur* | Expected on Test and Prod. Split into two releases (scenario 5) |
| Rename produced drop + create | The refactorlog was missing. Revert, redo with Refactor → Rename |
| `usp_AssertCompatible` fails during module deploy | Deploy the matching DB release first, or choose a module version that supports the current DB |
| Settings differ between environments unexpectedly | Check `Settings.<Env>.sql`, then run `Compare-Environment.ps1` |
| Migration ran in Dev but not in Test | Check it is listed in `Migrations.sql` and that Test deployed the newer dacpac |
| Import fails with a login error | Check server, port, SQL authentication, and `VIEW DEFINITION` permission |

---

## 15. Implementation checklist

| # | Item | Status |
|---|---|---|
| 1 | Schema as code project, publish profiles, Local scripts, Import script | EXISTS |
| 2 | Lookup data MERGE, dev sample data, DB version record | EXISTS |
| 3 | Rename `AppDb.refactorlog.xml` to `AppDb.refactorlog` | PLANNED |
| 4 | `app.Settings` table and Settings files (All + per environment) | PLANNED |
| 5 | Split lookups into one file per table | PLANNED |
| 6 | `app.MigrationHistory`, `Migrations/`, `New-Migration.ps1`, `.gitattributes` union rule | PLANNED |
| 7 | `Export-Settings.ps1` | PLANNED |
| 8 | `Compare-Environment.ps1` (drift report) | PLANNED |
| 9 | Per-module schemas and ownership list | PLANNED |
| 10 | `app.ModuleVersion`, `app.ModuleCompatibility`, `usp_AssertCompatible` | PLANNED |
| 11 | `Compatibility/modules.json` and `Releases/*.md` | PLANNED |
| 12 | CI: migration immutability, breaking-change check, idempotency check | PLANNED |
| 13 | GitHub workflow Prod stage with approval and script artifact | PLANNED |
| 14 | Fix the .NET / `sqlpackage` problem on the build and developer PCs | PLANNED |
| 15 | `git init`, remote, branch protection | PLANNED |

### Open questions

1. How many modules are there, and do they live in separate repositories and pipelines?
2. Can several modules run on different versions at the same time? (This document assumes yes.)
3. How many older module versions must stay supported at once?
4. Move existing tables into per-module schemas, or keep them in `dbo` with an ownership list?
5. GitHub Actions or Azure DevOps?
6. Should settings differ per environment? (This document assumes yes.)
