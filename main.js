import "regenerator-runtime/runtime"
import authConfig from "./auth_config.json";
import { Elm } from "./src/Main.elm";

// The Auth0 client, initialized in configureClient()
let auth0 = null;

/**
 * Starts the authentication flow
 */
const login = async(targetUrl) => {
    try {
        console.log("Logging in", targetUrl);

        const options = {
            redirect_uri: window.location.origin
        };

        if (targetUrl) {
            options.appState = { targetUrl };
        }

        await auth0.loginWithRedirect(options);
    } catch (err) {
        console.log("Log in failed", err);
    }
};

/**
 * Executes the logout flow
 */
const logout = () => {
    try {
        console.log("Logging out");
        auth0.logout({
            returnTo: window.location.origin
        });
    } catch (err) {
        console.log("Log out failed", err);
    }
};

/**
 * Initializes the Auth0 client
 */
const configureClient = async() => {
    auth0 = await createAuth0Client({
        domain: authConfig.domain,
        client_id: authConfig.clientId,
        cacheLocation: "localstorage",
    });
    window.auth0 = auth0;
};

const authenticateIfNeeded = async() => {
    await configureClient();

    const userDataExists = await auth0.isAuthenticated();

    if (userDataExists) {
        // If user is in browser state, use that user data
        console.log("> User is authenticated");
        window.history.replaceState({}, document.title, window.location.pathname);
        return;
    }

    console.log("> User not authenticated");

    // No user data in browser, try checking the query params for callback info
    const query = window.location.search;
    const shouldParseResult = query.includes("code=") && query.includes("state=");

    if (shouldParseResult) {
        // If URL contains callback query params, parse them and authenticate
        console.log("> Parsing redirect");
        try {
            await auth0.handleRedirectCallback();

            console.log("Logged in!");

            window.history.replaceState({}, document.title, window.location.pathname);
            return;
        } catch (err) {
            console.log("Error parsing redirect:", err);
        }
    }

    // No data to authenticate with, start login flow and redirect
    login();
}

// Will run when page finishes loading
window.onload = async() => {
    await authenticateIfNeeded();
    await runElmApp();
};

const runElmApp = async() => {
    try {
        const user = await auth0.getUser();

        const isProd = location.host.endsWith("jan.systems");
        const flags = {
            userData: {
                email: user.email,
                name: user.name,
                pictureUrl: user.picture,
            },
            apiURL: isProd ? "https://bookapi.jan.systems" : "http://localhost:5678",
        };

        const app = Elm.Main.init({
            node: document.getElementById("app"),
            flags,
        });

        app.ports.showAlert.subscribe((message) => window.alert(message));
        app.ports.requestLogout.subscribe(logout);
    } catch (err) {
        console.error(err);
    }
}