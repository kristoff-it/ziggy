import * as vscode from "vscode";
import { OutputChannel, TextEdit } from "vscode";
import { execCmd, getZiggyPath } from "./util";

export class ZiggyFormatProvider implements vscode.DocumentFormattingEditProvider {
    private _channel: OutputChannel;

    constructor(logChannel: OutputChannel) {
        this._channel = logChannel;
    }

    provideDocumentFormattingEdits(
        document: vscode.TextDocument,
    ): Thenable<TextEdit[]> {
        const logger = this._channel;
        return ziggyFormat(document)
            .then(({ stdout }) => {
                logger.clear();
                const lastLineId = document.lineCount - 1;
                const wholeDocument = new vscode.Range(
                    0,
                    0,
                    lastLineId,
                    document.lineAt(lastLineId).text.length,
                );
                return [new TextEdit(wholeDocument, stdout),];
            })
            .catch((reason) => {
                const config = vscode.workspace.getConfiguration("zig");

                logger.clear();
                logger.appendLine(reason.toString().replace("<stdin>", document.fileName));
                if (config.get<boolean>("revealOutputChannelOnFormattingError")) {
                    logger.show(true);
                }
                return null;
            });
    }
}

// Same as full document formatter for now
export class ZiggyRangeFormatProvider implements vscode.DocumentRangeFormattingEditProvider {
    private _channel: OutputChannel;
    constructor(logChannel: OutputChannel) {
        this._channel = logChannel;
    }

    provideDocumentRangeFormattingEdits(
        document: vscode.TextDocument,
    ): Thenable<TextEdit[]> {
        const logger = this._channel;
        return ziggyFormat(document)
            .then(({ stdout }) => {
                logger.clear();
                const lastLineId = document.lineCount - 1;
                const wholeDocument = new vscode.Range(
                    0,
                    0,
                    lastLineId,
                    document.lineAt(lastLineId).text.length,
                );
                return [new TextEdit(wholeDocument, stdout),];
            })
            .catch((reason) => {
                const config = vscode.workspace.getConfiguration("zig");

                logger.clear();
                logger.appendLine(reason.toString().replace("<stdin>", document.fileName));
                if (config.get<boolean>("revealOutputChannelOnFormattingError")) {
                    logger.show(true);
                }
                return null;
            });
    }
}

function ziggyFormat(document: vscode.TextDocument) {
    const ziggyPath = getZiggyPath();

    const options = {
        cmdArguments: ["fmt", "--stdin"],
        notFoundText: "Could not find ziggy. Please add ziggy to your PATH or specify a custom path to the ziggy binary in your settings.",
    };
    const format = execCmd(ziggyPath, options);

    format.stdin.write(document.getText());
    format.stdin.end();

    return format;
}