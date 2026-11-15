using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;
using System.Runtime.InteropServices;

internal static class NASAFormationLauncher
{
    [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
    private static extern int SetCurrentProcessExplicitAppUserModelID(string appId);

    [STAThread]
    private static int Main(string[] args)
    {
        SetCurrentProcessExplicitAppUserModelID("NASAFormation.Expedition");
        string root = AppDomain.CurrentDomain.BaseDirectory;
        string engine = Path.Combine(root, "runtime", "Godot.exe");
        string project = Path.Combine(root, "game");
        if (!File.Exists(engine) || !File.Exists(Path.Combine(project, "project.godot")))
        {
            MessageBox.Show("Extract the full ZIP and keep NASAFormation.exe beside the game and runtime folders.", "NASAFormation");
            return 1;
        }

        string options = "";
        if (Array.IndexOf(args, "--self-test") >= 0)
            options = " --headless --quit-after 750 -- --self-test";
        else if (Array.IndexOf(args, "--render-test") >= 0)
            options = " --quit-after 3600 -- --render-test";

        try
        {
            var start = new ProcessStartInfo(engine, "--path \"" + project + "\" --rendering-method gl_compatibility" + options);
            start.WorkingDirectory = root;
            string dataFolder = Path.Combine(root, "userdata");
            Directory.CreateDirectory(dataFolder);
            start.EnvironmentVariables["APPDATA"] = dataFolder;
            start.UseShellExecute = false;
            start.CreateNoWindow = true;
            using (Process process = Process.Start(start))
            {
                process.WaitForExit();
                return process.ExitCode;
            }
        }
        catch (Exception error)
        {
            MessageBox.Show(error.Message, "NASAFormation could not start");
            return 1;
        }
    }
}
