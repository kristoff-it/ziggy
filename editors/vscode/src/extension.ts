import * as path from 'path';
import { workspace, ExtensionContext, window, languages } from 'vscode';
import { ZiggyFormatProvider, ZiggyRangeFormatProvider } from './formatter';

import {
	LanguageClient,
	LanguageClientOptions,
	ServerOptions
} from 'vscode-languageclient/node';

let client: LanguageClient;

const logChannel = window.createOutputChannel("ziggy");

export function activate(context: ExtensionContext) {
    context.subscriptions.push(
        languages.registerDocumentFormattingEditProvider(
            [{ scheme: "file", language: "ziggy"}],
            new ZiggyFormatProvider(logChannel),
        ),
      );
      context.subscriptions.push(
        languages.registerDocumentRangeFormattingEditProvider(
            [{ scheme: "file", language: "ziggy"}],
            new ZiggyRangeFormatProvider(logChannel),
        ),
      );


	// If the extension is launched in debug mode then the debug server options are used
	// Otherwise the run options are used
	const serverOptions: ServerOptions = {
		run: { command: "ziggy", args: ["lsp"] },
        debug: { command: "ziggy", args: ["lsp"] },
	};

	// Options to control the language client
	const clientOptions: LanguageClientOptions = {
		// Register the server for plain text documents
        documentSelector: [
            { scheme: "file", language: 'ziggy' },
            { scheme: "file", language: 'ziggy_schema' },
        ],
		synchronize: {
			// Notify the server about file changes to '.clientrc files contained in the workspace
			fileEvents: workspace.createFileSystemWatcher('**/.zgy')
		}
	};

	// Create the language client and start the client.
    const client = new LanguageClient(
      "ziggy",
      "Ziggy Language Server",
      serverOptions,
      clientOptions
    );

    client.start().catch(reason => {
        window.showWarningMessage(`Failed to run Ziggy Language Server: ${reason}`);
    }).then(() => {
        client.getFeature("textDocument/formatting").clear();
    });
}

export function deactivate(): Thenable<void> | undefined {
	if (!client) {
		return undefined;
	}
	return client.stop();
}