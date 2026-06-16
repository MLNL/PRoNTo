# Instructions for Mac Users

Download the latest version of PRoNTo from the [Releases page](https://github.com/MLNL/PRoNTo_public/releases).

---

## (Necessary step) Disable Mac's Malware Check

Since SPM and PRoNTo are downloaded from external developers, you will see warning messages like *"Application cannot be opened because the developer cannot be verified"*. This stops you from running PRoNTo.

Instead of disabling Gatekeeper system-wide, you can approve only the specific files that are blocked. This is safer and does not affect any other applications on your Mac.

**Step 1 — Find the blocked file**

When you see the warning *"cannot be opened because the developer cannot be verified"*, note the name of the file (e.g. a `.mex` file inside the PRoNTo or SPM folder).

**Step 2 — Remove the quarantine flag from that file only**

Open Terminal and run:

```shell
$ xattr -d com.apple.quarantine /path/to/the/blocked/file
```

To clear all quarantine flags recursively across the entire PRoNTo folder:

```shell
$ xattr -dr com.apple.quarantine /path/to/PRoNTo
```

**Step 3 — Alternatively, approve via System Settings**

1. Open **System Settings → Privacy & Security**
2. Scroll down to the *Security* section
3. You will see a message saying the app was blocked — click **Allow Anyway**
4. Re-open MATLAB and try running PRoNTo again

---

## (Potentially necessary steps) When you run into compiler problems

Follow these steps if you encounter issues with your Mac version. Xcode is a compiler used to compile C/C++ code (found in some external libraries used by PRoNTo) into `.mex` files, which MATLAB uses to run C/C++ code. Pre-compiled `.mex` files are included in the libraries, but some Mac versions may require recompilation.

### 1. Download Xcode

Download Xcode from the **App Store**. Note that Xcode is a large application — download it before your practical session.

### 2. Install Xcode Command Line Tools

```shell
$ xcode-select --install
```

### 3. Activate Compilers

It is common to run into problems when using `mex` in MATLAB. For troubleshooting, see the [MathWorks support page](https://uk.mathworks.com/matlabcentral/answers/470698-error-using-mex-no-supported-compiler-was-found-on-mac).

```shell
$ sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

$ sudo xcodebuild -license accept
```
