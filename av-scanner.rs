use std::env;
use std::fs::File;
use std::io::{self, Write};
use std::process::Command;

fn main() {
    check_python_and_tkinter();
    install_dependencies();
    run_clamscan();
}

fn check_python_and_tkinter() {
    let python_version = Command::new("python3")
        .arg("--version")
        .output()
        .expect("Failed to execute python3");

    if !python_version.status.success() {
        eprintln!("Python 3 is required but not installed on your system.");
        eprintln!("Please visit https://www.python.org/downloads/ to download and install Python 3.");
        std::process::exit(1);
    }

    let tkinter_check = Command::new("python3")
        .arg("-c")
        .arg("import tkinter")
        .output()
        .expect("Failed to execute python3");

    if !tkinter_check.status.success() {
        eprintln!("Tkinter is required but not installed on your system.");
        eprintln!("Please install Tkinter for Python 3. You can learn more at https://tkdocs.com/tutorial/install.html");
        std::process::exit(1);
    }
}

// TODO: ADD function for the package manager check, or just use the default system package manager
