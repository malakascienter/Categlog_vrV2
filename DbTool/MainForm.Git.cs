using System.Diagnostics;
using System.Text;
using System.Text.RegularExpressions;

namespace DbTool;

// The "Git" tab: everything from first commit to pull request, without leaving the tool.
public sealed partial class MainForm
{
    private readonly ComboBox cmbBranch = new() { Dock = DockStyle.Fill, DropDownStyle = ComboBoxStyle.DropDown };
    private readonly ListView lstFiles = new()
    {
        Dock = DockStyle.Fill, View = View.Details, CheckBoxes = true, FullRowSelect = true,
        HideSelection = false, GridLines = true, Height = 130
    };
    private readonly CheckBox chkBuildFirst = new() { Text = "Build before commit (blocks a broken commit)", AutoSize = true, Checked = true };
    private readonly TextBox txtGitName = new() { Dock = DockStyle.Fill };
    private readonly TextBox txtGitEmail = new() { Dock = DockStyle.Fill };
    private readonly Label lblGit = new() { AutoSize = true, Font = new Font("Segoe UI", 9f, FontStyle.Bold), Margin = new Padding(3, 6, 3, 3) };

    private static readonly string[] ConflictCodes = { "UU", "AA", "DD", "AU", "UA", "DU", "UD" };

    // ------------------------------------------------------------------ layout
    private Control BuildGitTab()
    {
        var stack = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1 };

        // Setup: remote + identity
        var setup = Grid(3, 3);
        var btnRemote = new Button { Text = "Set remote", AutoSize = true };
        btnRemote.Click += async (_, _) => await Guard(async () => { await GitSetRemoteAsync(); await RefreshGitAsync(); });
        var btnIdent = new Button { Text = "Save identity", AutoSize = true };
        btnIdent.Click += async (_, _) => await Guard(GitSaveIdentityAsync);
        AddRow(setup, 0, "Remote URL", txtRemote, btnRemote);
        AddRow(setup, 1, "Your name", txtGitName, null);
        AddRow(setup, 2, "Your email", txtGitEmail, btnIdent);
        var gSetup = new GroupBox { Text = "Setup (once)", Dock = DockStyle.Top, AutoSize = true, Padding = new Padding(6) };
        var setupFlow = new FlowLayoutPanel { Dock = DockStyle.Top, AutoSize = true, WrapContents = false };
        setupFlow.Controls.Add(GitAct("Init repo", "git init + first commit", GitInitAsync));
        var setupStack = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1 };
        setupStack.Controls.Add(setup); setupStack.Controls.Add(setupFlow);
        gSetup.Controls.Add(setupStack);

        // Branch row
        var gBranch = new GroupBox { Text = "Branch", Dock = DockStyle.Top, AutoSize = true, Padding = new Padding(6) };
        var brGrid = Grid(3, 1);
        AddRow(brGrid, 0, "Branch name", cmbBranch, null);
        var brFlow = new FlowLayoutPanel { Dock = DockStyle.Top, AutoSize = true, WrapContents = false };
        brFlow.Controls.Add(GitAct("Switch", "git switch <branch>", () => GitSwitchAsync(false)));
        brFlow.Controls.Add(GitAct("Create new", "git switch -c <branch> (from the current one)", () => GitSwitchAsync(true)));
        brFlow.Controls.Add(GitAct("Merge into current", "git merge --no-ff <branch>", GitMergeAsync));
        brFlow.Controls.Add(GitAct("Delete branch", "git branch -d <branch>", GitDeleteBranchAsync));
        brFlow.Controls.Add(GitAct("Abort merge", "git merge --abort / git rebase --abort", GitAbortAsync));
        brFlow.Controls.Add(GitAct("Refresh", "Reload branches and changed files", () => Task.CompletedTask));
        var brStack = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1 };
        brStack.Controls.Add(lblGit); brStack.Controls.Add(brGrid); brStack.Controls.Add(brFlow);
        gBranch.Controls.Add(brStack);

        // Changes
        var gChanges = new GroupBox { Text = "Changes (tick the files to commit; double-click a file to see its diff)", Dock = DockStyle.Top, AutoSize = true, Padding = new Padding(6) };
        lstFiles.Columns.Add("Status", 130); lstFiles.Columns.Add("File", 700);
        lstFiles.DoubleClick += async (_, _) => await Guard(GitDiffSelectedAsync);
        var selFlow = new FlowLayoutPanel { Dock = DockStyle.Top, AutoSize = true, WrapContents = false };
        var all = new Button { Text = "Tick all", AutoSize = true }; all.Click += (_, _) => { foreach (ListViewItem i in lstFiles.Items) i.Checked = true; };
        var none = new Button { Text = "Untick all", AutoSize = true }; none.Click += (_, _) => { foreach (ListViewItem i in lstFiles.Items) i.Checked = false; };
        var open = new Button { Text = "Open file", AutoSize = true }; open.Click += (_, _) => OpenSelectedFile();
        selFlow.Controls.AddRange(new Control[] { all, none, open });
        selFlow.Controls.Add(GitAct("Diff", "git diff for the selected file", GitDiffSelectedAsync));
        selFlow.Controls.Add(GitAct("Mark resolved", "git add the ticked conflict files", GitResolveAsync));
        selFlow.Controls.Add(GitAct("Discard ticked", "THROW AWAY the ticked changes (asks first)", GitDiscardAsync));
        lstFiles.Height = 130;
        var chStack = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1 };
        chStack.Controls.Add(lstFiles); chStack.Controls.Add(selFlow);
        gChanges.Controls.Add(chStack);

        // Commit and sync
        var gCommit = new GroupBox { Text = "Commit and sync", Dock = DockStyle.Top, AutoSize = true, Padding = new Padding(6) };
        var cGrid = Grid(3, 2);
        AddRow(cGrid, 0, "Commit message", txtMessage, null);
        AddRow(cGrid, 1, "Tag name", txtBranch, null);
        var cFlow = new FlowLayoutPanel { Dock = DockStyle.Top, AutoSize = true, WrapContents = false };
        cFlow.Controls.Add(GitAct("Commit ticked", "Commit only the ticked files", GitCommitAsync));
        cFlow.Controls.Add(GitAct("Fetch", "git fetch --prune", () => Git("fetch", "--prune")));
        cFlow.Controls.Add(GitAct("Pull", "git pull --rebase", () => Git("pull", "--rebase")));
        cFlow.Controls.Add(GitAct("Push", "git push -u origin HEAD", () => Git("push", "-u", "origin", "HEAD")));
        cFlow.Controls.Add(GitAct("Stash", "Put local changes aside", () => Git("stash", "push", "-u", "-m", "DbProjectTool")));
        cFlow.Controls.Add(GitAct("Stash pop", "Bring stashed changes back", () => Git("stash", "pop")));
        // Second row: fixed (no wrapping) so no button can ever be pushed out of sight.
        var cFlow2 = new FlowLayoutPanel { Dock = DockStyle.Top, AutoSize = true, WrapContents = false };
        cFlow2.Controls.Add(GitAct("Undo last commit", "git reset --soft HEAD~1 (keeps your files)", GitUndoAsync));
        cFlow2.Controls.Add(GitAct("Log", "Last 30 commits", () => Git("log", "--oneline", "--graph", "--decorate", "-n", "30")));
        cFlow2.Controls.Add(GitAct("Create tag + push", "git tag <name>, then push it", GitTagAsync));
        cFlow2.Controls.Add(GitAct("List tags", "git tag", () => Git("tag", "--sort=-v:refname")));
        var pr = new Button { Text = "Open Pull Request", AutoSize = true };
        pr.Click += async (_, _) => await Guard(GitOpenPullRequestAsync);
        cFlow2.Controls.Add(pr);
        var cStack = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1 };
        cStack.Controls.Add(chkBuildFirst); cStack.Controls.Add(cGrid); cStack.Controls.Add(cFlow); cStack.Controls.Add(cFlow2);
        gCommit.Controls.Add(cStack);

        stack.Controls.Add(gSetup);
        stack.Controls.Add(gBranch);
        stack.Controls.Add(gChanges);
        stack.Controls.Add(gCommit);
        return stack;
    }

    // Runs a git action, then refreshes branch + file list.
    private Button GitAct(string text, string tip, Func<Task> run) =>
        Action(text, tip, async () => { await run(); await RefreshGitAsync(); });

    // ----------------------------------------------------------------- helpers
    private async Task<(int Code, string Out)> GitOut(params string[] args)
    {
        var psi = new ProcessStartInfo("git")
        {
            RedirectStandardOutput = true, RedirectStandardError = true, UseShellExecute = false, CreateNoWindow = true,
            WorkingDirectory = txtProject.Text, StandardOutputEncoding = Encoding.UTF8
        };
        psi.Environment["GIT_TERMINAL_PROMPT"] = "0";
        foreach (var a in args) psi.ArgumentList.Add(a);
        using var p = Process.Start(psi)!;
        var o = p.StandardOutput.ReadToEndAsync();
        var e = p.StandardError.ReadToEndAsync();
        await p.WaitForExitAsync();
        await e;
        return (p.ExitCode, (await o).TrimEnd());
    }

    private async Task<int> GitRaw(params string[] args)
    {
        if (!Directory.Exists(txtProject.Text)) throw new InvalidOperationException("Select the project folder first.");
        return await RunAsync("git", args, txtProject.Text);
    }

    private async Task Git(params string[] args)
    {
        SetBusy(true, "git " + args[0] + "…");
        int code;
        try { code = await GitRaw(args); }
        catch (System.ComponentModel.Win32Exception) { throw new InvalidOperationException("git was not found. Install Git for Windows from https://git-scm.com and restart this tool."); }
        if (code != 0) throw new InvalidOperationException("git " + args[0] + " failed (exit code " + code + "). See the log.");
        status.Text = "git " + args[0] + " done";
    }

    private async Task<bool> IsRepoAsync()
    {
        try { return (await GitOut("rev-parse", "--is-inside-work-tree")).Code == 0; }
        catch { return false; }
    }

    private async Task<bool> HasCommitsAsync() => (await GitOut("rev-parse", "--verify", "--quiet", "HEAD")).Code == 0;

    private IEnumerable<(string Code, string Path)> Ticked() =>
        lstFiles.CheckedItems.Cast<ListViewItem>().Select(i => ((string)i.Tag!, i.SubItems[1].Text));

    private string? SelectedPath() => lstFiles.SelectedItems.Count == 0 ? null : lstFiles.SelectedItems[0].SubItems[1].Text;

    // ----------------------------------------------------------------- refresh
    private async Task RefreshGitAsync()
    {
        try
        {
            if (!await IsRepoAsync())
            {
                lblGit.Text = "Not a git repository yet – click \"Init repo\" in Setup.";
                lstFiles.Items.Clear(); cmbBranch.Items.Clear();
                return;
            }
            var head = (await GitOut("status", "-sb")).Out.Split('\n').FirstOrDefault() ?? "";
            lblGit.Text = head.TrimStart('#', ' ');

            var current = (await GitOut("branch", "--show-current")).Out;
            var branches = (await GitOut("for-each-ref", "--format=%(refname:short)", "refs/heads")).Out
                .Split('\n', StringSplitOptions.RemoveEmptyEntries).Select(s => s.Trim()).ToArray();
            var typed = cmbBranch.Text;
            cmbBranch.Items.Clear(); cmbBranch.Items.AddRange(branches);
            cmbBranch.Text = string.IsNullOrWhiteSpace(typed) || branches.Contains(typed) ? (typed.Length > 0 && branches.Contains(typed) ? typed : current) : typed;

            if (txtRemote.Text.Length == 0)
            { var r = await GitOut("remote", "get-url", "origin"); if (r.Code == 0) txtRemote.Text = r.Out; }
            if (txtGitName.Text.Length == 0) txtGitName.Text = (await GitOut("config", "user.name")).Out;
            if (txtGitEmail.Text.Length == 0) txtGitEmail.Text = (await GitOut("config", "user.email")).Out;

            var st = await GitOut("-c", "core.quotepath=false", "status", "--porcelain=v1", "-uall");
            lstFiles.BeginUpdate();
            lstFiles.Items.Clear();
            foreach (var line in st.Out.Split('\n', StringSplitOptions.RemoveEmptyEntries))
            {
                if (line.Length < 4) continue;
                var xy = line[..2];
                var path = line[3..].Trim('"');
                var arrow = path.IndexOf(" -> ", StringComparison.Ordinal);
                if (arrow >= 0) path = path[(arrow + 4)..];
                var conflict = ConflictCodes.Contains(xy);
                var item = new ListViewItem(Describe(xy)) { Tag = xy, Checked = !conflict };
                item.SubItems.Add(path);
                if (conflict) { item.ForeColor = Color.Firebrick; item.Font = new Font(lstFiles.Font, FontStyle.Bold); }
                lstFiles.Items.Add(item);
            }
            lstFiles.EndUpdate();
            if (lstFiles.Items.Cast<ListViewItem>().Any(i => ConflictCodes.Contains((string)i.Tag!)))
                lblGit.Text += "   ⚠ CONFLICTS: fix the red files, then \"Mark resolved\" and Commit";
        }
        catch (Exception ex) { lblGit.Text = "git: " + ex.Message; }
    }

    private static string Describe(string xy) => xy switch
    {
        "??" => "New (untracked)",
        _ when ConflictCodes.Contains(xy) => "CONFLICT",
        _ when xy.Contains('D') => "Deleted",
        _ when xy.Contains('R') => "Renamed",
        _ when xy.Contains('A') => "Added",
        _ => "Modified"
    };

    // ----------------------------------------------------------------- actions
    private async Task GitInitAsync()
    {
        if (await IsRepoAsync()) { Write("Already a git repository.", Color.Khaki); status.Text = "Already a repository"; return; }
        await Git("init", "-b", "main");
        await Git("add", "-A");
        await Git("commit", "-m", "Initial commit: database project");
        Write("Repository created. Next: set the remote URL, then Push.", Color.LightGreen);
    }

    private async Task GitSetRemoteAsync()
    {
        var url = txtRemote.Text.Trim();
        if (url.Length == 0) throw new InvalidOperationException("Enter the remote URL first (for example https://github.com/you/DBProject.git).");
        var exists = await GitRaw("remote", "get-url", "origin") == 0;
        await Git("remote", exists ? "set-url" : "add", "origin", url);
        await Git("remote", "-v");
    }

    private async Task GitSaveIdentityAsync()
    {
        if (txtGitName.Text.Trim().Length == 0 || txtGitEmail.Text.Trim().Length == 0)
            throw new InvalidOperationException("Enter both your name and email.");
        await Git("config", "--global", "user.name", txtGitName.Text.Trim());
        await Git("config", "--global", "user.email", txtGitEmail.Text.Trim());
        Write("Identity saved. Commits will use this name and email.", Color.LightGreen);
    }

    private async Task GitCommitAsync()
    {
        var msg = txtMessage.Text.Trim();
        if (msg.Length == 0) throw new InvalidOperationException("Enter a commit message first.");
        var files = Ticked().ToList();
        if (files.Count == 0) throw new InvalidOperationException("Tick at least one file to commit.");
        if (files.Any(f => ConflictCodes.Contains(f.Code)))
            throw new InvalidOperationException("Some ticked files still have conflicts. Fix them and click \"Mark resolved\" first.");

        if (chkBuildFirst.Checked && File.Exists(ProjectFile))
        {
            Write("Checking the project builds before committing…", Color.DeepSkyBlue);
            await BuildAsync(false);   // throws if the build fails, so a broken commit is never made
        }

        if (await HasCommitsAsync()) await GitRaw("reset", "-q");           // start from an empty index
        var add = new List<string> { "add", "-A", "--" }; add.AddRange(files.Select(f => f.Path));
        await Git(add.ToArray());
        await Git("commit", "-m", msg);
        txtMessage.Clear();
    }

    private async Task GitSwitchAsync(bool create)
    {
        var name = cmbBranch.Text.Trim();
        if (name.Length == 0) throw new InvalidOperationException("Enter a branch name first.");
        if (!Regex.IsMatch(name, @"^[A-Za-z0-9._/\-]+$")) throw new InvalidOperationException("Branch names may only contain letters, numbers and . _ / -");
        var exists = (await GitOut("rev-parse", "--verify", "--quiet", "refs/heads/" + name)).Code == 0;
        if (create && exists) throw new InvalidOperationException($"Branch '{name}' already exists. Use Switch.");
        if (!create && !exists) throw new InvalidOperationException($"Branch '{name}' does not exist. Use Create new.");
        await Git(create ? new[] { "switch", "-c", name } : new[] { "switch", name });
    }

    private async Task GitMergeAsync()
    {
        var name = cmbBranch.Text.Trim();
        var current = (await GitOut("branch", "--show-current")).Out;
        if (name.Length == 0 || name == current) throw new InvalidOperationException("Pick a different branch in the Branch box to merge into the current one.");
        if (MessageBox.Show(this, $"Merge '{name}' into '{current}'?", "Confirm merge", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes) return;
        SetBusy(true, "git merge…");
        var code = await GitRaw("merge", "--no-ff", name);
        if (code != 0)
        {
            Write("Merge stopped. If files show CONFLICT: open them, keep the right lines, Mark resolved, then Commit. Or click Abort merge.", Color.Orange);
            status.Text = "Merge needs attention";
        }
        else status.Text = "Merged";
    }

    private async Task GitDeleteBranchAsync()
    {
        var name = cmbBranch.Text.Trim();
        var current = (await GitOut("branch", "--show-current")).Out;
        if (name.Length == 0 || name == current) throw new InvalidOperationException("Select a branch other than the current one to delete.");
        if (name is "main" or "master") throw new InvalidOperationException("Refusing to delete " + name + ".");
        if (MessageBox.Show(this, $"Delete branch '{name}'? (only if it is fully merged)", "Confirm", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) != DialogResult.Yes) return;
        await Git("branch", "-d", name);
    }

    private async Task GitAbortAsync()
    {
        var gitDir = (await GitOut("rev-parse", "--git-dir")).Out;
        var full = Path.IsPathRooted(gitDir) ? gitDir : Path.Combine(txtProject.Text, gitDir);
        if (File.Exists(Path.Combine(full, "MERGE_HEAD"))) await Git("merge", "--abort");
        else if (Directory.Exists(Path.Combine(full, "rebase-merge")) || Directory.Exists(Path.Combine(full, "rebase-apply"))) await Git("rebase", "--abort");
        else Write("Nothing to abort.", Color.Khaki);
    }

    private async Task GitResolveAsync()
    {
        var files = Ticked().Where(f => ConflictCodes.Contains(f.Code)).Select(f => f.Path).ToList();
        if (files.Count == 0) throw new InvalidOperationException("Tick the conflict (red) files you have fixed.");
        var args = new List<string> { "add", "--" }; args.AddRange(files);
        await Git(args.ToArray());
    }

    private async Task GitDiscardAsync()
    {
        var files = Ticked().ToList();
        if (files.Count == 0) throw new InvalidOperationException("Tick the files to discard.");
        var list = string.Join("\n", files.Take(15).Select(f => "  " + f.Path)) + (files.Count > 15 ? $"\n  …and {files.Count - 15} more" : "");
        if (MessageBox.Show(this, "This PERMANENTLY throws away your changes to:\n\n" + list + "\n\nThis cannot be undone. Continue?",
                "Discard changes", MessageBoxButtons.YesNo, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2) != DialogResult.Yes) return;
        foreach (var (code, path) in files)
        {
            if (code == "??")
            {
                var full = Path.Combine(txtProject.Text, path);
                if (File.Exists(full)) File.Delete(full);
            }
            else await Git("restore", "--source=HEAD", "--staged", "--worktree", "--", path);
        }
        Write("Discarded.", Color.Khaki);
    }

    private async Task GitUndoAsync()
    {
        if (MessageBox.Show(this, "Undo the last commit? Your file changes are kept and become uncommitted again.\n(Don't do this if you already pushed it.)",
                "Undo last commit", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes) return;
        await Git("reset", "--soft", "HEAD~1");
    }

    private async Task GitDiffSelectedAsync()
    {
        var path = SelectedPath();
        if (path == null) throw new InvalidOperationException("Select a file in the list first.");
        var code = ((string)lstFiles.SelectedItems[0].Tag!);
        if (code == "??") { Write("New file – nothing to compare. Use Open file to view it.", Color.Khaki); return; }
        await Git("diff", "HEAD", "--", path);
    }

    private void OpenSelectedFile()
    {
        var path = SelectedPath();
        if (path == null) { status.Text = "Select a file first"; return; }
        var full = Path.Combine(txtProject.Text, path);
        if (File.Exists(full)) Process.Start(new ProcessStartInfo(full) { UseShellExecute = true });
    }

    private async Task GitTagAsync()
    {
        var name = txtBranch.Text.Trim();
        if (name.Length == 0) throw new InvalidOperationException("Enter the tag name first (for example db-v1.0.0).");
        if (MessageBox.Show(this, $"Create tag '{name}' on the current commit and push it?\n\nA tag on main can start a Prod release in CI.",
                "Confirm tag", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes) return;
        await Git("tag", name);
        await Git("push", "origin", name);
    }

    private async Task GitOpenPullRequestAsync()
    {
        var url = (await GitOut("remote", "get-url", "origin")).Out;
        if (url.Length == 0) throw new InvalidOperationException("No remote set. Enter the Remote URL and click Set remote.");
        var branch = (await GitOut("branch", "--show-current")).Out;

        // git@github.com:owner/repo.git  ->  https://github.com/owner/repo
        var m = Regex.Match(url, @"^git@([^:]+):(.+)$");
        var web = m.Success ? $"https://{m.Groups[1].Value}/{m.Groups[2].Value}" : url;
        web = Regex.Replace(web, @"\.git$", "");
        web = Regex.Replace(web, @"//[^/@]+@", "//");   // drop any user info

        string target;
        if (web.Contains("github.com", StringComparison.OrdinalIgnoreCase) && branch.Length > 0)
            target = $"{web}/compare/{Uri.EscapeDataString(branch).Replace("%2F", "/")}?expand=1";
        else if ((web.Contains("dev.azure.com") || web.Contains("visualstudio.com")) && branch.Length > 0)
            target = $"{web}/pullrequestcreate?sourceRef={Uri.EscapeDataString(branch)}";
        else target = web;

        Write("Opening: " + target, Color.DeepSkyBlue);
        Process.Start(new ProcessStartInfo(target) { UseShellExecute = true });
        status.Text = "Opened in browser (push the branch first if it is new)";
    }
}
