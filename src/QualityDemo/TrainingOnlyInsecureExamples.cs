using System.Diagnostics;
using System.Net.Http;
using System.Security.Cryptography;

namespace QualityDemo;

/// <summary>
/// Intentionally insecure patterns for scanner demonstrations only.
/// Do not call these methods or copy them into production code.
/// </summary>
public static class TrainingOnlyInsecureExamples
{
    // DEMO ONLY: hard-coded credential should be reported by secret/security rules.
    private const string DemoPassword = "P@ssword-For-Scanner-Demo-Only";

    /// <summary>
    /// Demonstrates weak cryptography and predictable random generation findings.
    /// </summary>
    public static string CreateWeakDemoFingerprint(string input)
    {
        // DEMO ONLY: MD5 is cryptographically broken and must not protect sensitive data.

        // DEMO ONLY: Random is predictable and must not generate security tokens.
        Random predictableRandom = new();
#pragma warning disable CA5351 // Intentional scanner training fixture.
        byte[] bytes = MD5.HashData(System.Text.Encoding.UTF8.GetBytes($"{input}-{predictableRandom.Next()}"));
#pragma warning restore CA5351

        return Convert.ToHexString(bytes);
    }

    /// <summary>
    /// Demonstrates disabled TLS certificate validation.
    /// </summary>
    public static HttpClient CreateUnsafeHttpClient()
    {
        HttpClientHandler handler = new()
        {
            // DEMO ONLY: accepting every certificate enables man-in-the-middle attacks.
            ServerCertificateCustomValidationCallback = (_, _, _, _) => true,
        };

        return new HttpClient(handler);
    }

    /// <summary>
    /// Demonstrates data-flow review points for command and file-path injection.
    /// </summary>
    public static void DemonstrateUntrustedInputSinks(string userSuppliedPath, string userSuppliedCommand)
    {
        // DEMO ONLY: validate/canonicalize paths and enforce an allowed root before file access.
        string fileContents = File.ReadAllText(userSuppliedPath);

        // DEMO ONLY: do not pass untrusted input to the operating system shell.
        Process.Start("cmd.exe", $"/c {userSuppliedCommand}");

        Console.WriteLine($"Training-only content length: {fileContents.Length}; demo password length: {DemoPassword.Length}");
    }
}
