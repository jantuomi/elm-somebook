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
        client_id: authConfig.clientId
    });
    window.auth0 = auth0;
};

// Will run when page finishes loading
window.onload = async() => {
    await configureClient();

    // If unable to parse the history hash, default to the root URL
    // if (!showContentFromUrl(window.location.pathname)) {
    //     showContentFromUrl("/");
    //     window.history.replaceState({ url: "/" }, {}, "/");
    // }

    const isAuthenticated = await auth0.isAuthenticated();

    if (isAuthenticated) {
        console.log("> User is authenticated");
        window.history.replaceState({}, document.title, window.location.pathname);
        // runElmApp();
        return;
    }

    console.log("> User not authenticated");

    const query = window.location.search;
    const shouldParseResult = query.includes("code=") && query.includes("state=");

    if (shouldParseResult) {
        console.log("> Parsing redirect");
        try {
            const result = await auth0.handleRedirectCallback();

            if (result.appState && result.appState.targetUrl) {
                showContentFromUrl(result.appState.targetUrl);
            }

            console.log("Logged in!");
            return runElmApp();
        } catch (err) {
            console.log("Error parsing redirect:", err);
        }
    }

    login();
};

const runElmApp = () => {
    try {
        const app = Elm.Main.init({
            node: document.getElementById("app")
        });

        app.ports.showAlert.subscribe((message) => window.alert(message));
        app.ports.requestLogout.subscribe(logout);
    } catch (err) {
        console.error(err);
    }
}