# Swift Environment Template for iOS Development with Cursor

Credit to [Thomas Ricouard](https://github.com/dimillian) for the original blog post [How to use Cursor for iOS development](https://dimillian.medium.com/how-to-use-cursor-for-ios-development-54b912c23941)

## Overview

This template provides an alternative iOS development setup using Cursor—a fork of VSCode with AI-assisted code editing—rather than relying solely on Xcode. It is designed around a Swift environment that leverages modern developer productivity tools and streamlined workflows.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- **Cursor:** A code editor that enhances the VSCode experience with AI-powered features (free with a subscription for advanced features).
- **Homebrew:** To install necessary command-line tools.
- **Xcode Build Server:** Allows SourceKit-LSP to function outside of Xcode, providing features like jump-to-definition, reference lookup, and more.

Additionally, install the following tools via Homebrew:

- **xcbeautify:** To pretty print the `xcodebuild` output.
- **swiftformat:** To format Swift code consistently.

## Setup Instructions

1. **Install Xcode Build Server:**
   Install via Homebrew:

   ```bash
   brew install xcode-build-server
   ```

2. **Install xcbeautify:**
   Install via Homebrew:

   ```bash
   brew install xcbeautify
   ```

3. **Install swiftformat:**
   If not already installed, use:

   ```bash
   brew install swiftformat
   ```

4. **Launch Cursor and Install Extensions:**
   - Open Cursor.
   - Navigate to the Extensions tab and install:
     - **Swift Language Support:** For syntax highlighting and other essential Swift features.
     - **Sweetpad:** This extension brings a suite of commands for managing builds using the Xcode Build Server. Sweetpad [homepage](https://sweetpad.hyzyla.dev/) and [Github](https://github.com/hyzyla/sweetpad).

5. **Configure Sweetpad:**
   - Open the command palette (CMD+SHIFT+P).
   - Select **Sweetpad: Generate Build Server Config**. This creates a `buildServer.json` file at the root of your project directory, enabling full SourceKit-LSP functionality within Cursor.

6. **Build and Run Your Project:**
   - Use the Sweetpad tab (or execute Build & Run from the command palette) to build your project. Running the project at least once will generate the necessary metadata (autocomplete, jump-to-definition, etc.).

## Debugging Configuration

To attach the debugger using Cursor:

1. Build your project as described.
2. Press F5 to attach the debugger.
   - You may be prompted to create a launch configuration for debug mode—select **Sweetpad** when prompted.
   - Alternatively, use the Run & Debug tab’s "Attach to running app" action, which will build, launch, and debug your app automatically.

A sample configuration in your `./vscode/launch.json` looks like this:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "sweetpad-lldb",
            "request": "launch",
            "name": "Attach to running app (SweetPad)",
            "preLaunchTask": "sweetpad: launch"
        }
    ]
}
```

## Key Features with Cursor

- **AI-Assisted Autocompletion:** Cursor not only leverages standard SourceKit completion but also provides AI-based suggestions that adapt to your project’s context. This helps you write code faster and keeps your style intact.
  
- **Inline Editing via CMD+K:** Quickly generate context-specific code or initiate refactorings by using an in-editor prompt.
  
- **Integrated Chat:** Use the chat panel (triggered by CMD+L) to query coding questions, discuss design decisions, or request code edits. This keeps your workflow smooth without switching contexts.

- **Composer for Bulk Edits:** Automate generation of multiple files or large-scale refactoring tasks using detailed prompts—a robust addition to the development workflow.

## Conclusion

This Swift environment template with Cursor as an alternative to Xcode harnesses modern developer tools to offer a faster, more modular, and AI-enhanced development experience. Whether you are building a SwiftUI Mastodon client or any other iOS project, you now have a setup that promises efficiency and enhanced productivity.

Happy coding!
