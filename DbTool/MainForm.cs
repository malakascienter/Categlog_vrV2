using System.Diagnostics;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.Data.SqlClient;

namespace DbTool;

public sealed class Settings
{
    public string ProjectDir { get; set; } = "";
    public string SqlPackage { get; set; } = "";
    public string Server { get; set; } = @"(localdb)\MSSQLLocalDB";
    public string Database { get; set; } = "AppDb";
    public int Auth { get; set; } = 0;           // 0 = Windows, 1 = SQL login
    public string User { get; set; } = "";
    public string Environment { get; set; } = "Local";
    public bool Encrypt { get; set; } = false;
    public bool OnlyDbo { get; set; } = false;
    public bool IncludeSecurity { get; set; } = false;
    public string RemoteUrl { get; set; } = "";
}

public sealed partial class MainForm : Form
{
    private const string SqlPackageVersion = "162.5.57"; // runs on .NET 8
    private static readonly string[] ProtectedFolders = { "Scripts", "PublishProfiles", "app", "bin", "obj" };

    private static readonly string SettingsFile = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "DbProjectTool", "settings.json");
    private static readonly string ToolDir = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".dbproject", "sqlpackage");

    private readonly TextBox txtProject = new() { Dock = DockStyle.Fill };
    private readonly TextBox txtSqlPackage = new() { Dock = DockStyle.Fill };
    private readonly TextBox txtServer = new() { Dock = DockStyle.Fill };
    private readonly TextBox txtDatabase = new() { Dock = DockStyle.Fill };
    private readonly ComboBox cmbAuth = new() { Dock = DockStyle.Fill, DropDownStyle = ComboBoxStyle.DropDownList };
    private readonly TextBox txtUser = new() { Dock = DockStyle.Fill };
    private readonly TextBox txtPassword = new() { Dock = DockStyle.Fill, UseSystemPasswordChar = true };
    private readonly ComboBox cmbEnv = new() { Dock = DockStyle.Fill, DropDownStyle = ComboBoxStyle.DropDownList };
    private readonly CheckBox chkEncrypt = new() { Text = "Encrypt connection", AutoSize = true };
    private readonly CheckBox chkOnlyDbo = new() { Text = "Import only dbo schema", AutoSize = true };
    private readonly CheckBox chkSecurity = new() { Text = "Import users/permissions", AutoSize = true };
    private readonly RichTextBox log = new()
    {
        Dock = DockStyle.Fill, ReadOnly = true, BackColor = Color.FromArgb(24, 24, 24),
        ForeColor = Color.Gainsboro, Font = new Font("Consolas", 9.5f), WordWrap = false
    };
    private readonly TextBox txtRemote = new() { Dock = DockStyle.Fill };
    private readonly TextBox txtMessage = new() { Dock = DockStyle.Fill, PlaceholderText = "Commit message, e.g. Add Phone to Customer" };
    private readonly TextBox txtBranch = new() { Dock = DockStyle.Fill, PlaceholderText = "Branch or tag name, e.g. feature/add-phone or db-v1.0.0" };
    private readonly Label status = new() { Dock = DockStyle.Fill, TextAlign = ContentAlignment.MiddleLeft };
    private readonly List<Button> actionButtons = new();
    private readonly Button btnCancel = new() { Text = "Cancel", Enabled = false, AutoSize = true };
    private Process? current;
    private bool cancelled;

    public MainForm()
    {
        Text = "DB Project Tool – schema, settings and scripts";
        Width = 1060; Height = 900; MinimumSize = new Size(900, 700);
        StartPosition = FormStartPosition.CenterScreen;
        Font = new Font("Segoe UI", 9f);

        cmbAuth.Items.AddRange(new object[] { "Windows authentication", "SQL login (user + password)" });
        cmbEnv.Items.AddRange(new object[] { "Local", "Dev", "Test", "Prod" });
        cmbAuth.SelectedIndexChanged += (_, _) => { var sql = cmbAuth.SelectedIndex == 1; txtUser.Enabled = sql; txtPassword.Enabled = sql; };

        BuildLayout();
        LoadSettings();
        StartFlushTimer();
        Shown += async (_, _) => await FindSqlPackageAsync();
        FormClosing += (_, _) => SaveSettings();
    }

    // ---------------------------------------------------------------- layout
    private void BuildLayout()
    {
        var root = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 5, Padding = new Padding(10) };
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));          // project
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 380));     // tabs
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));          // toolbar
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));      // log
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 24));      // status

        // Project / tools
        var gProject = new GroupBox { Text = "1. Project and tools", Dock = DockStyle.Top, AutoSize = true, Padding = new Padding(8) };
        var tProject = Grid(3, 2);
        var btnBrowse = new Button { Text = "Browse…", AutoSize = true };
        btnBrowse.Click += (_, _) => BrowseProject();
        var btnInstall = new Button { Text = "Install sqlpackage", AutoSize = true };
        btnInstall.Click += async (_, _) => await InstallSqlPackageAsync();
        AddRow(tProject, 0, "Project folder", txtProject, btnBrowse);
        AddRow(tProject, 1, "sqlpackage.exe", txtSqlPackage, btnInstall);
        gProject.Controls.Add(tProject);

        // Connection
        var gConn = new GroupBox { Text = "2. Database connection", Dock = DockStyle.Top, AutoSize = true, Padding = new Padding(8) };
        var tConn = Grid(3, 6);
        var btnTest = new Button { Text = "Test connection", AutoSize = true };
        btnTest.Click += async (_, _) => await TestConnectionAsync();
        AddRow(tConn, 0, "Server", txtServer, null);
        AddRow(tConn, 1, "Database", txtDatabase, null);
        AddRow(tConn, 2, "Authentication", cmbAuth, null);
        AddRow(tConn, 3, "User", txtUser, null);
        AddRow(tConn, 4, "Password", txtPassword, null);
        AddRow(tConn, 5, "Environment profile", cmbEnv, btnTest);
        var opts = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true };
        opts.Controls.AddRange(new Control[] { chkEncrypt, chkOnlyDbo, chkSecurity });
        var connStack = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1, RowCount = 2 };
        connStack.Controls.Add(tConn, 0, 0);
        connStack.Controls.Add(opts, 0, 1);
        gConn.Controls.Add(connStack);

        // Actions
        var gAct = new GroupBox { Text = "3. Actions", Dock = DockStyle.Top, AutoSize = true, Padding = new Padding(8) };
        var flow = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, WrapContents = true };
        flow.Controls.Add(Action("Build project", "Build the AppDb project and create the .dacpac", () => BuildAsync()));
        flow.Controls.Add(Action("Publish to database", "Create or update the database so it matches the project", () => PublishAsync()));
        flow.Controls.Add(Action("Create SQL script", "Write the change script without running it", () => ScriptAsync()));
        flow.Controls.Add(Action("Preview changes (report)", "Show what a publish would change", () => ReportAsync()));
        flow.Controls.Add(Action("Import database → project", "Turn an existing database into one .sql file per object", () => ImportAsync()));
        gAct.Controls.Add(flow);

        var btnOut = new Button { Text = "Open output folder", AutoSize = true };
        btnOut.Click += (_, _) => OpenOutput();
        var btnClear = new Button { Text = "Clear log", AutoSize = true };
        btnClear.Click += (_, _) => log.Clear();
        btnCancel.Click += (_, _) => { cancelled = true; try { current?.Kill(true); } catch { } };
        var toolbar = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true };
        toolbar.Controls.AddRange(new Control[] { btnCancel, btnClear, btnOut });

        var dbPage = new TabPage("Database") { AutoScroll = true, Padding = new Padding(6) };
        var dbStack = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1, RowCount = 2 };
        dbStack.Controls.Add(gConn, 0, 0);
        dbStack.Controls.Add(gAct, 0, 1);
        dbPage.Controls.Add(dbStack);

        var gitPage = new TabPage("Git") { AutoScroll = true, Padding = new Padding(6) };
        gitPage.Controls.Add(BuildGitTab());

        var tabs = new TabControl { Dock = DockStyle.Fill };
        tabs.TabPages.Add(dbPage);
        tabs.TabPages.Add(gitPage);
        tabs.SelectedIndexChanged += async (_, _) => { if (tabs.SelectedTab == gitPage) await RefreshGitAsync(); };

        root.Controls.Add(gProject, 0, 0);
        root.Controls.Add(tabs, 0, 1);
        root.Controls.Add(toolbar, 0, 2);
        root.Controls.Add(log, 0, 3);
        root.Controls.Add(status, 0, 4);
        Controls.Add(root);
    }

    private static TableLayoutPanel Grid(int cols, int rows)
    {
        var t = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = cols, RowCount = rows };
        t.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 130));
        t.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        t.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        return t;
    }

    private static void AddRow(TableLayoutPanel t, int row, string label, Control input, Control? extra)
    {
        t.Controls.Add(new Label { Text = label, AutoSize = true, Anchor = AnchorStyles.Left, Margin = new Padding(3, 7, 3, 3) }, 0, row);
        t.Controls.Add(input, 1, row);
        if (extra != null) t.Controls.Add(extra, 2, row);
    }

    private Button Action(string text, string tip, Func<Task> run)
    {
        var b = new Button { Text = text, AutoSize = true, Padding = new Padding(6, 3, 6, 3) };
        new ToolTip().SetToolTip(b, tip);
        b.Click += async (_, _) => await Guard(run);
        actionButtons.Add(b);
        return b;
    }

    // -------------------------------------------------------------- settings
    private void LoadSettings()
    {
        var s = new Settings();
        try { if (File.Exists(SettingsFile)) s = JsonSerializer.Deserialize<Settings>(File.ReadAllText(SettingsFile)) ?? s; } catch { }
        if (string.IsNullOrWhiteSpace(s.ProjectDir)) s.ProjectDir = GuessProjectDir();
        txtProject.Text = s.ProjectDir; txtSqlPackage.Text = s.SqlPackage;
        txtServer.Text = s.Server; txtDatabase.Text = s.Database;
        cmbAuth.SelectedIndex = s.Auth; txtUser.Text = s.User;
        cmbEnv.SelectedItem = s.Environment; if (cmbEnv.SelectedIndex < 0) cmbEnv.SelectedIndex = 0;
        chkEncrypt.Checked = s.Encrypt; chkOnlyDbo.Checked = s.OnlyDbo; chkSecurity.Checked = s.IncludeSecurity;
        txtRemote.Text = s.RemoteUrl;
    }

    private void SaveSettings()
    {
        try
        {
            Directory.CreateDirectory(Path.GetDirectoryName(SettingsFile)!);
            var s = new Settings
            {
                ProjectDir = txtProject.Text, SqlPackage = txtSqlPackage.Text, Server = txtServer.Text,
                Database = txtDatabase.Text, Auth = cmbAuth.SelectedIndex, User = txtUser.Text,
                Environment = cmbEnv.SelectedItem?.ToString() ?? "Local", Encrypt = chkEncrypt.Checked,
                OnlyDbo = chkOnlyDbo.Checked, IncludeSecurity = chkSecurity.Checked, RemoteUrl = txtRemote.Text
            };
            File.WriteAllText(SettingsFile, JsonSerializer.Serialize(s, new JsonSerializerOptions { WriteIndented = true }));
        }
        catch { /* settings are a convenience only; the password is never saved */ }
    }

    private static string GuessProjectDir()
    {
        foreach (var start in new[] { AppContext.BaseDirectory, Directory.GetCurrentDirectory() })
        {
            for (var d = new DirectoryInfo(start); d != null; d = d.Parent)
                if (File.Exists(Path.Combine(d.FullName, "AppDb", "AppDb.sqlproj"))) return d.FullName;
        }
        return "";
    }

    private void BrowseProject()
    {
        using var dlg = new FolderBrowserDialog { Description = "Select the folder that contains AppDb\\AppDb.sqlproj", SelectedPath = txtProject.Text };
        if (dlg.ShowDialog(this) == DialogResult.OK) txtProject.Text = dlg.SelectedPath;
    }

    // ------------------------------------------------------------- plumbing
    private string ProjectFile => Path.Combine(txtProject.Text, "AppDb", "AppDb.sqlproj");
    private string ProjectDir => Path.Combine(txtProject.Text, "AppDb");
    private string OutputDir => Path.Combine(txtProject.Text, "deploy-output");
    private string Env => cmbEnv.SelectedItem?.ToString() ?? "Local";
    private string Config => Env == "Local" ? "Debug" : "Release";

    private string ConnectionString(string? database = null)
    {
        var b = new SqlConnectionStringBuilder
        {
            DataSource = txtServer.Text.Trim(),
            InitialCatalog = database ?? txtDatabase.Text.Trim(),
            TrustServerCertificate = true,
            Encrypt = chkEncrypt.Checked ? SqlConnectionEncryptOption.Mandatory : SqlConnectionEncryptOption.Optional,
            ConnectTimeout = 15
        };
        if (cmbAuth.SelectedIndex == 0) b.IntegratedSecurity = true;
        else { b.UserID = txtUser.Text.Trim(); b.Password = txtPassword.Text; }
        return b.ConnectionString;
    }

    // Output is queued from any thread and written to the window in batches,
    // so a chatty build can never flood (and freeze) the UI thread.
    private readonly System.Collections.Concurrent.ConcurrentQueue<(string Text, Color Color)> pending = new();
    private System.Windows.Forms.Timer? flushTimer;

    private void Write(string text, Color? color = null)
    {
        pending.Enqueue((text, color ?? Color.Gainsboro));
        if (flushTimer == null && !InvokeRequired) StartFlushTimer();
    }

    private void StartFlushTimer()
    {
        flushTimer = new System.Windows.Forms.Timer { Interval = 100 };
        flushTimer.Tick += (_, _) => FlushLog();
        flushTimer.Start();
    }

    private void FlushLog()
    {
        if (pending.IsEmpty) return;
        var sb = new StringBuilder();
        var lastColor = Color.Gainsboro;
        log.SuspendLayout();
        int n = 0;
        while (n < 400 && pending.TryDequeue(out var item))
        {
            if (item.Color != lastColor && sb.Length > 0) { AppendChunk(sb.ToString(), lastColor); sb.Clear(); }
            lastColor = item.Color; sb.AppendLine(item.Text); n++;
        }
        if (sb.Length > 0) AppendChunk(sb.ToString(), lastColor);
        if (log.TextLength > 400_000) { log.Select(0, log.TextLength - 300_000); log.SelectedText = ""; }
        log.SelectionStart = log.TextLength;
        log.ScrollToCaret();
        log.ResumeLayout();
    }

    private void AppendChunk(string text, Color color)
    {
        log.SelectionStart = log.TextLength;
        log.SelectionColor = color;
        log.AppendText(text);
    }

    private static string Mask(string s) => Regex.Replace(s, @"(Password|Pwd)=[^;""]*", "$1=*****", RegexOptions.IgnoreCase);

    private void SetBusy(bool busy, string text)
    {
        foreach (var b in actionButtons) b.Enabled = !busy;
        btnCancel.Enabled = busy;
        status.Text = text;
        UseWaitCursor = busy;
    }

    private async Task Guard(Func<Task> work)
    {
        cancelled = false;
        try { await work(); }
        catch (Exception ex) { Write("ERROR: " + ex.Message, Color.Tomato); status.Text = "Failed"; MessageBox.Show(this, ex.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Error); }
        finally { SetBusy(false, status.Text); }
    }

    private async Task<int> RunAsync(string exe, IEnumerable<string> args, string? workDir = null)
    {
        var psi = new ProcessStartInfo(exe)
        {
            RedirectStandardOutput = true, RedirectStandardError = true, UseShellExecute = false,
            CreateNoWindow = true, StandardOutputEncoding = Encoding.UTF8, StandardErrorEncoding = Encoding.UTF8
        };
        if (workDir != null) psi.WorkingDirectory = workDir;
        psi.Environment["MSBUILDDISABLENODEREUSE"] = "1";      // no lingering build nodes holding our pipes
        psi.Environment["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1";
        psi.Environment["DOTNET_NOLOGO"] = "1";
        psi.Environment["GIT_TERMINAL_PROMPT"] = "0";          // never wait for a console prompt
        foreach (var a in args) psi.ArgumentList.Add(a);
        Write("> " + Path.GetFileName(exe) + " " + Mask(string.Join(' ', args.Select(a => a.Contains(' ') ? "\"" + a + "\"" : a))), Color.DeepSkyBlue);

        using var p = new Process { StartInfo = psi };
        current = p;
        p.OutputDataReceived += (_, e) => { if (e.Data != null) Write(Mask(e.Data)); };
        p.ErrorDataReceived += (_, e) => { if (e.Data != null) Write(Mask(e.Data), Color.Orange); };
        p.Start(); p.BeginOutputReadLine(); p.BeginErrorReadLine();
        // Poll for exit instead of WaitForExitAsync(): that one also waits for the output pipes
        // to close, which never happens if a child process (e.g. an MSBuild node) keeps them open.
        while (!p.HasExited) await Task.Delay(150);
        await Task.Delay(400);                                  // let the last output lines arrive
        current = null;
        if (cancelled) throw new OperationCanceledException("Cancelled.");
        return p.ExitCode;
    }

    private void RequireProject()
    {
        if (!File.Exists(ProjectFile)) throw new InvalidOperationException("Project not found. Select the folder that contains AppDb\\AppDb.sqlproj.");
    }

    private string SqlPackageExe()
    {
        var p = txtSqlPackage.Text.Trim();
        if (p.Length == 0 || !File.Exists(p)) throw new InvalidOperationException("sqlpackage.exe not found. Click \"Install sqlpackage\" or browse to it.");
        return p;
    }

    private string Profile()
    {
        var f = Path.Combine(ProjectDir, "PublishProfiles", Env + ".publish.xml");
        if (!File.Exists(f)) throw new InvalidOperationException("Publish profile not found: " + f);
        return f;
    }

    // ------------------------------------------------------------ sqlpackage
    private async Task FindSqlPackageAsync()
    {
        if (txtSqlPackage.Text.Length > 0 && await WorksAsync(txtSqlPackage.Text)) { status.Text = "Ready"; return; }
        var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        var candidates = new List<string> { Path.Combine(ToolDir, "sqlpackage.exe"), Path.Combine(home, ".dotnet", "tools", "sqlpackage.exe") };
        candidates.AddRange((Environment.GetEnvironmentVariable("PATH") ?? "").Split(';', StringSplitOptions.RemoveEmptyEntries)
            .Select(d => { try { return Path.Combine(d.Trim('"'), "sqlpackage.exe"); } catch { return ""; } }));
        foreach (var c in candidates.Where(File.Exists))
            if (await WorksAsync(c)) { txtSqlPackage.Text = c; status.Text = "Ready"; return; }
        status.Text = "sqlpackage is missing or broken – click \"Install sqlpackage\"";
        Write("sqlpackage was not found or cannot start. Click \"Install sqlpackage\" (installs version " + SqlPackageVersion + ", which runs on .NET 8).", Color.Orange);
    }

    private static async Task<bool> WorksAsync(string exe)
    {
        try
        {
            var psi = new ProcessStartInfo(exe, "/Version") { RedirectStandardOutput = true, RedirectStandardError = true, UseShellExecute = false, CreateNoWindow = true };
            using var p = Process.Start(psi)!;
            var done = p.WaitForExitAsync();
            if (await Task.WhenAny(done, Task.Delay(20000)) != done) { try { p.Kill(true); } catch { } return false; }
            return p.ExitCode == 0;
        }
        catch { return false; }
    }

    private async Task InstallSqlPackageAsync()
    {
        await Guard(async () =>
        {
            SetBusy(true, "Installing sqlpackage…");
            Directory.CreateDirectory(ToolDir);
            var code = await RunAsync("dotnet", new[] { "tool", "update", "--tool-path", ToolDir, "microsoft.sqlpackage", "--version", SqlPackageVersion });
            if (code != 0) throw new InvalidOperationException("Install failed. Is the .NET SDK installed?");
            var exe = Path.Combine(ToolDir, "sqlpackage.exe");
            if (!await WorksAsync(exe)) throw new InvalidOperationException("Installed, but sqlpackage does not start. A matching .NET runtime may be missing.");
            txtSqlPackage.Text = exe; status.Text = "sqlpackage installed";
            Write("sqlpackage installed: " + exe, Color.LightGreen);
        });
    }

    // ---------------------------------------------------------------- actions
    private async Task TestConnectionAsync()
    {
        await Guard(async () =>
        {
            SetBusy(true, "Testing connection…");
            await using var cn = new SqlConnection(ConnectionString("master"));
            await cn.OpenAsync();
            await using var cmd = cn.CreateCommand();
            cmd.CommandText = "SELECT @@VERSION";
            var ver = ((string?)await cmd.ExecuteScalarAsync() ?? "").Split('\n')[0];
            cmd.CommandText = "SELECT COUNT(*) FROM sys.databases WHERE name = @n";
            cmd.Parameters.AddWithValue("@n", txtDatabase.Text.Trim());
            var exists = (int)(await cmd.ExecuteScalarAsync())! > 0;
            Write("Connected: " + ver, Color.LightGreen);
            Write(exists ? $"Database '{txtDatabase.Text}' exists." : $"Database '{txtDatabase.Text}' does not exist yet – Publish will create it.", exists ? Color.LightGreen : Color.Khaki);
            status.Text = "Connection OK";
        });
    }

    private async Task<string> BuildAsync(bool announce = true)
    {
        RequireProject();
        SetBusy(true, "Building…");
        var code = await RunAsync("dotnet", new[] { "build", ProjectFile, "-c", Config, "--nologo", "-v", "minimal", "-nodeReuse:false", "-p:UseSharedCompilation=false" }, txtProject.Text);
        if (code != 0) throw new InvalidOperationException("Build failed. Fix the errors shown in the log.");
        var dacpac = Path.Combine(ProjectDir, "bin", Config, "AppDb.dacpac");
        if (announce) { Write("Build succeeded: " + dacpac, Color.LightGreen); status.Text = "Build succeeded"; }
        return dacpac;
    }

    private async Task PublishAsync()
    {
        var exe = SqlPackageExe(); RequireProject();
        if (Env != "Local" && MessageBox.Show(this, $"Publish to {Env.ToUpper()} server '{txtServer.Text}', database '{txtDatabase.Text}'?\n\nTip: create and review the SQL script first.",
                "Confirm publish", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) != DialogResult.Yes) return;
        var dacpac = await BuildAsync(false);
        SetBusy(true, "Publishing…");
        var code = await RunAsync(exe, new[] { "/Action:Publish", "/SourceFile:" + dacpac, "/Profile:" + Profile(),
            "/TargetConnectionString:" + ConnectionString(), "/TargetDatabaseName:" + txtDatabase.Text.Trim() });
        if (code != 0) throw new InvalidOperationException("Publish failed (exit code " + code + "). See the log.");
        Write("Database is up to date.", Color.LightGreen); status.Text = "Published";
    }

    private async Task ScriptAsync()
    {
        var exe = SqlPackageExe(); RequireProject();
        var dacpac = await BuildAsync(false);
        Directory.CreateDirectory(OutputDir);
        var file = Path.Combine(OutputDir, $"AppDb_{Env}_{DateTime.Now:yyyyMMdd_HHmmss}.sql");
        SetBusy(true, "Creating script…");
        var code = await RunAsync(exe, new[] { "/Action:Script", "/SourceFile:" + dacpac, "/Profile:" + Profile(),
            "/TargetConnectionString:" + ConnectionString(), "/TargetDatabaseName:" + txtDatabase.Text.Trim(), "/OutputPath:" + file });
        if (code != 0) throw new InvalidOperationException("Script generation failed. See the log.");
        Write("Script saved: " + file, Color.LightGreen); status.Text = "Script created";
        Process.Start(new ProcessStartInfo(file) { UseShellExecute = true });
    }

    private async Task ReportAsync()
    {
        var exe = SqlPackageExe(); RequireProject();
        var dacpac = await BuildAsync(false);
        Directory.CreateDirectory(OutputDir);
        var file = Path.Combine(OutputDir, $"AppDb_{Env}_{DateTime.Now:yyyyMMdd_HHmmss}.report.xml");
        SetBusy(true, "Creating report…");
        var code = await RunAsync(exe, new[] { "/Action:DeployReport", "/SourceFile:" + dacpac, "/Profile:" + Profile(),
            "/TargetConnectionString:" + ConnectionString(), "/TargetDatabaseName:" + txtDatabase.Text.Trim(), "/OutputPath:" + file });
        if (code != 0) throw new InvalidOperationException("Report failed. See the log.");
        Write("Report saved: " + file, Color.LightGreen); status.Text = "Report created";
        Process.Start(new ProcessStartInfo(file) { UseShellExecute = true });
    }

    private async Task ImportAsync()
    {
        var exe = SqlPackageExe(); RequireProject();
        var temp = Path.Combine(Path.GetTempPath(), "AppDbImport_" + Guid.NewGuid().ToString("N"));
        try
        {
            SetBusy(true, "Reading database…");
            var skip = (!chkSecurity.Checked).ToString();
            var code = await RunAsync(exe, new[] { "/Action:Extract", "/SourceConnectionString:" + ConnectionString(), "/TargetFile:" + temp,
                "/p:ExtractTarget=SchemaObjectType", "/p:IgnorePermissions=" + skip, "/p:IgnoreUserLoginMappings=" + skip,
                "/p:ExtractApplicationScopedObjectsOnly=" + skip });
            if (code != 0) throw new InvalidOperationException("Extract failed. Check the server, database name, login and permissions.");

            var folders = Directory.GetDirectories(temp).Select(d => new DirectoryInfo(d)).ToList();
            if (chkOnlyDbo.Checked) folders = folders.Where(f => f.Name.Equals("dbo", StringComparison.OrdinalIgnoreCase)).ToList();
            folders = folders.Where(f => !ProtectedFolders.Contains(f.Name, StringComparer.OrdinalIgnoreCase)).ToList();
            if (folders.Count == 0) throw new InvalidOperationException("Nothing was extracted.");

            var list = string.Join("\n", folders.Select(f => "   AppDb\\" + f.Name + "\\"));
            if (MessageBox.Show(this, "These project folders will be REPLACED with the database version:\n\n" + list +
                    "\n\n(Scripts, PublishProfiles and app are never touched.)\n\nContinue?", "Confirm import",
                    MessageBoxButtons.YesNo, MessageBoxIcon.Warning) != DialogResult.Yes) { Write("Import cancelled."); return; }

            foreach (var f in folders)
            {
                var target = Path.Combine(ProjectDir, f.Name);
                if (Directory.Exists(target)) Directory.Delete(target, true);
                CopyDir(f.FullName, target);
            }
            var count = Directory.EnumerateFiles(ProjectDir, "*.sql", SearchOption.AllDirectories)
                .Count(p => !Regex.IsMatch(p, @"\\(Scripts|bin|obj)\\"));
            Write($"Done. Project now has {count} object files.", Color.LightGreen);
            Write("Next: click Build and fix any errors, then update Scripts\\PostDeploy data files.", Color.Khaki);
            status.Text = "Import finished";
        }
        finally { try { if (Directory.Exists(temp)) Directory.Delete(temp, true); } catch { } }
    }

    private static void CopyDir(string from, string to)
    {
        Directory.CreateDirectory(to);
        foreach (var f in Directory.GetFiles(from)) File.Copy(f, Path.Combine(to, Path.GetFileName(f)), true);
        foreach (var d in Directory.GetDirectories(from)) CopyDir(d, Path.Combine(to, Path.GetFileName(d)));
    }

    private void OpenOutput()
    {
        Directory.CreateDirectory(OutputDir);
        Process.Start(new ProcessStartInfo(OutputDir) { UseShellExecute = true });
    }
}
