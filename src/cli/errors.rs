#![allow(clippy::large_enum_variant)]
#![allow(dead_code)]

use crate::rustup_mode::CompletionCommand;

use std::io;
use std::path::PathBuf;

use clap::Shell;
use error_chain::error_chain;
use rustup::dist::temp;

error_chain! {
    links {
        Rustup(rustup::Error, rustup::ErrorKind);
    }

    foreign_links {
        Temp(temp::Error);
        Io(io::Error);
        Term(term::Error);
    }

    errors {
        PermissionDenied {
            description("permission denied")
        }
        ToolchainNotInstalled(t: String) {
            description("toolchain is not installed")
            display("toolchain '{}' is not installed", t)
        }
        InvalidToolchainName(t: String) {
            description("invalid toolchain name")
            display("invalid toolchain name: '{}'", t)
        }
        InfiniteRecursion {
            description("infinite recursion detected")
        }
        NoExeName {
            description("couldn't determine self executable name")
        }
        NotSelfInstalled(p: PathBuf) {
            description("rustup is not installed")
            display("rustup is not installed at '{}'", p.display())
        }
        WindowsUninstallMadness {
            description("failure during windows uninstall")
        }
        UnsupportedCompletionShell(shell: Shell, cmd: CompletionCommand) {
            description("completion script for shell not yet supported for tool")
            display("{} does not currently support completions for {}", cmd, shell)
        }
        TargetAllSpecifiedWithTargets(t: Vec<String>) {
            description(
                "the `all` target, which installs all available targets, \
                 cannot be combined with other targets"
            )
            display("`rustup target add {}` includes `all`", t.join(" "))
        }
        WritingShellProfile {
            path: PathBuf,
        } {
            description("could not amend shell profile")
            display("could not amend shell profile: '{}'", path.display())
        }
    }
}
