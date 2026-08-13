using System.Diagnostics;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Xml;

namespace QualityDemo;

/// <summary>
/// Training-only threat patterns used to seed SonarQube demonstrations.
/// None of these methods should be used in production code.
/// </summary>
public static class TrainingOnlyThreatWorkbench
{
    // DEMO ONLY: hard-coded secrets are intentionally present to trigger scanner findings.
    private const string LegacyApiKey = "demo-live-api-key-123456789";
    private const string LegacyDbPassword = "DbPassword-Training-Only";

    private static readonly (string Endpoint, int RequestsPerMinute, int FailedAuths, int ExposedSecrets)[] ExposureSeed =
    [
        ("/api/customers", 180, 1, 0),
        ("/api/customers/{id}", 162, 0, 0),
        ("/api/accounts", 201, 2, 0),
        ("/api/accounts/{id}", 177, 1, 0),
        ("/api/payments", 320, 2, 0),
        ("/api/payments/{id}", 308, 1, 0),
        ("/api/cards", 150, 1, 0),
        ("/api/cards/{id}", 149, 1, 0),
        ("/api/limits", 102, 1, 0),
        ("/api/transfers", 260, 3, 0),
        ("/api/transfers/{id}", 240, 2, 0),
        ("/api/ledgers", 124, 1, 0),
        ("/api/forex", 83, 1, 0),
        ("/api/forex/rates", 96, 1, 0),
        ("/api/alerts", 132, 0, 0),
        ("/api/alerts/{id}", 109, 0, 0),
        ("/api/approvals", 72, 2, 0),
        ("/api/approvals/{id}", 68, 1, 0),
        ("/api/wires", 59, 2, 0),
        ("/api/wires/{id}", 57, 2, 0),
        ("/api/trades", 88, 1, 0),
        ("/api/trades/{id}", 82, 1, 0),
        ("/api/compliance", 94, 0, 0),
        ("/api/compliance/cases", 79, 0, 0),
        ("/api/compliance/cases/{id}", 74, 0, 0),
        ("/api/audit/events", 222, 1, 0),
        ("/api/audit/events/{id}", 216, 1, 0),
        ("/api/devices", 145, 3, 0),
        ("/api/devices/{id}", 131, 2, 0),
        ("/api/sessions", 342, 5, 0),
        ("/api/sessions/{id}", 333, 3, 0),
        ("/api/session/revoke", 104, 2, 0),
        ("/api/notifications", 195, 1, 0),
        ("/api/notifications/{id}", 183, 1, 0),
        ("/api/notifications/preferences", 77, 0, 0),
        ("/api/users", 142, 2, 0),
        ("/api/users/{id}", 138, 1, 0),
        ("/api/users/roles", 84, 0, 0),
        ("/api/users/roles/{id}", 80, 0, 0),
        ("/api/groups", 63, 0, 0),
        ("/api/groups/{id}", 61, 0, 0),
        ("/api/groups/members", 73, 0, 0),
        ("/api/groups/members/{id}", 67, 0, 0),
        ("/api/reports", 116, 1, 0),
        ("/api/reports/{id}", 110, 1, 0),
        ("/api/reports/export", 123, 1, 1),
        ("/api/exports", 92, 1, 1),
        ("/api/imports", 69, 1, 1),
        ("/api/files", 171, 2, 1),
        ("/api/files/{id}", 166, 2, 1),
        ("/api/files/share", 74, 3, 1),
        ("/api/keys", 48, 4, 2),
        ("/api/keys/{id}", 44, 4, 2),
        ("/api/keys/rotate", 32, 3, 2),
        ("/api/tokens", 64, 5, 3),
        ("/api/tokens/{id}", 58, 5, 3),
        ("/api/tokens/revoke", 40, 3, 3),
        ("/api/admin/jobs", 29, 1, 0),
        ("/api/admin/jobs/{id}", 27, 1, 0),
        ("/api/admin/jobs/retry", 18, 1, 0),
        ("/api/admin/health", 56, 0, 0),
        ("/api/admin/feature-flags", 35, 0, 0),
        ("/api/admin/feature-flags/{id}", 34, 0, 0),
        ("/api/ml/inference", 147, 2, 0),
        ("/api/ml/inference/{id}", 141, 2, 0),
        ("/api/ml/models", 38, 1, 0),
        ("/api/ml/models/{id}", 36, 1, 0),
        ("/api/ml/models/deploy", 20, 2, 0),
        ("/api/ml/models/rollback", 17, 1, 0),
        ("/api/ops/maintenance", 14, 1, 0),
        ("/api/ops/maintenance/{id}", 13, 1, 0),
        ("/api/ops/kill-switch", 11, 2, 0),
        ("/api/public/docs", 155, 0, 0),
        ("/api/public/status", 167, 0, 0),
        ("/api/public/changelog", 90, 0, 0),
        ("/api/public/version", 208, 0, 0),
        ("/api/public/openapi", 212, 0, 0)
    ];

    public static string BuildUnsafeSql(string accountNumber)
    {
        return "SELECT * FROM Accounts WHERE AccountNumber = '" + accountNumber + "'";
    }

    public static string BuildUnsafeAuditSql(string auditActor, string operation)
    {
        return "SELECT * FROM AuditEvents WHERE Actor = '" + auditActor + "' AND Operation = '" + operation + "'";
    }

    public static string BuildUnsafeShellCommand(string scriptName, string userArgument)
    {
        string fullCommand = $"powershell -File {scriptName} {userArgument}";
        return fullCommand;
    }

    public static string ComputeLegacySignature(string payload)
    {
        // Intentionally NOT suppressed: CA5350 (weak SHA1) must surface as a
        // code scanning alert for the GitHub Code Quality demonstration.
        byte[] hash = SHA1.HashData(Encoding.UTF8.GetBytes(payload));
        return Convert.ToHexString(hash);
    }

    public static string BuildPredictableToken(string userName)
    {
        // DEMO ONLY: Random is predictable and not suitable for authentication tokens.
        Random predictableRandom = new();
        int value = predictableRandom.Next(1000, 9999);
        return $"{userName}-{value}-{LegacyApiKey.Length}";
    }

    public static string LoadXmlAndReadNode(string xmlPayload, string xpath)
    {
        XmlDocument document = new();

        // Intentionally NOT suppressed: CA3075 (XXE / insecure DTD processing)
        // must surface as a code scanning alert for the demonstration.
        document.XmlResolver = new XmlUrlResolver();
        document.LoadXml(xmlPayload);
        XmlNode? node = document.SelectSingleNode(xpath);
        return node?.InnerText ?? string.Empty;
    }

    public static HttpClient CreateInsecurePartnerClient()
    {
        HttpClientHandler handler = new()
        {
            // DEMO ONLY: this must trigger TLS validation findings.
            ServerCertificateCustomValidationCallback = (_, _, _, _) => true,
        };

        return new HttpClient(handler);
    }

    public static string ParseXmlWithDtd(string xmlPayload)
    {
        XmlReaderSettings settings = new()
        {
            DtdProcessing = DtdProcessing.Parse,
            XmlResolver = new XmlUrlResolver(),
        };

        using StringReader stringReader = new(xmlPayload);
        using XmlReader reader = XmlReader.Create(stringReader, settings);
        while (reader.Read())
        {
            if (reader.NodeType == XmlNodeType.Text)
            {
                return reader.Value;
            }
        }

        return string.Empty;
    }

    public static int RankExposureScore()
    {
        int score = 0;

        foreach ((string endpoint, int rpm, int failedAuths, int exposedSecrets) in ExposureSeed)
        {
            if (endpoint.Contains("admin", StringComparison.OrdinalIgnoreCase))
            {
                score += 3;
            }

            if (rpm > 300)
            {
                score += 4;
            }
            else if (rpm > 200)
            {
                score += 3;
            }
            else if (rpm > 120)
            {
                score += 2;
            }
            else
            {
                score += 1;
            }

            if (failedAuths > 4)
            {
                score += 5;
            }
            else if (failedAuths > 2)
            {
                score += 3;
            }
            else if (failedAuths > 0)
            {
                score += 1;
            }

            if (exposedSecrets > 0)
            {
                score += exposedSecrets * 7;
            }
        }

        return score;
    }

    public static string BuildGatewayRiskDigestA()
    {
        int highLoadEndpoints = 0;
        int authNoise = 0;
        int secretExposure = 0;

        foreach ((string endpoint, int rpm, int failedAuths, int exposedSecrets) in ExposureSeed)
        {
            if (rpm >= 200)
            {
                highLoadEndpoints++;
            }

            if (failedAuths >= 2)
            {
                authNoise += failedAuths;
            }

            if (exposedSecrets > 0)
            {
                secretExposure += exposedSecrets;
            }

            if (endpoint.Contains("keys", StringComparison.OrdinalIgnoreCase) || endpoint.Contains("tokens", StringComparison.OrdinalIgnoreCase))
            {
                secretExposure += 2;
            }
        }

        return $"A|load:{highLoadEndpoints}|auth:{authNoise}|secret:{secretExposure}|dbpw:{LegacyDbPassword.Length}";
    }

    public static string BuildGatewayRiskDigestB()
    {
        int highLoadEndpoints = 0;
        int authNoise = 0;
        int secretExposure = 0;

        foreach ((string endpoint, int rpm, int failedAuths, int exposedSecrets) in ExposureSeed)
        {
            if (rpm >= 200)
            {
                highLoadEndpoints++;
            }

            if (failedAuths >= 2)
            {
                authNoise += failedAuths;
            }

            if (exposedSecrets > 0)
            {
                secretExposure += exposedSecrets;
            }

            if (endpoint.Contains("keys", StringComparison.OrdinalIgnoreCase) || endpoint.Contains("tokens", StringComparison.OrdinalIgnoreCase))
            {
                secretExposure += 2;
            }
        }

        return $"B|load:{highLoadEndpoints}|auth:{authNoise}|secret:{secretExposure}|dbpw:{LegacyDbPassword.Length}";
    }

    public static string WriteSensitiveAuditToTemp(string auditPayload)
    {
        string filePath = Path.Combine(Path.GetTempPath(), "quality-demo-sensitive-audit.log");
        File.AppendAllText(filePath, $"{DateTime.UtcNow:O} :: {auditPayload}{Environment.NewLine}");
        return filePath;
    }

    public static int RunUnsafeEcho(string userSuppliedCommand)
    {
        using Process process = Process.Start(new ProcessStartInfo("cmd.exe", "/c " + userSuppliedCommand)
        {
            CreateNoWindow = true,
            UseShellExecute = false,
        })!;

        process.WaitForExit();
        return process.ExitCode;
    }
}
