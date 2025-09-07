# Firmware2 
## A tool for setting the correct recovery firmware on keyrolled devices.

> [!NOTE]  
> This program is only meant for Chromebooks/Chromeboxes.
> It comes with ABSOLUTELY NO WARRANTY.
> It is meant for Nissa, Corsola and Dedede ONLY
----
## Usage
To use this, first make sure that you are connected to an unmanaged network, and that you are signed into a valid account on the Chromebook. 
Then switch to VT2 and enter chronos by typing `chronos` 
Make sure you use `chronos` and not `root`

> [!CAUTION]  
> Make sure that you know the exact device name for your chromebook.
> All ChromeOS devices have a board name, which determines which firmware, OS build, etc a device uses.
> The board name is listed `chrome://version`. Look for `nissa`, `dedede` or `corsola`. If you are one of those specific boards, you can unkeyroll.
Then type this command to download and execute the script
----

```
curl -LO https://raw.githubusercontent.com/Cruzy22k/Firmware2/main/firmware.sh && sudo bash firmware.sh
```

> [!NOTE]  
> Don't worry if it gives you a warning about noexec mount, this is intended behaviour 


Follow the prompts, ensuring you have firmware and hardware Write-Protect Disabled as this will not work with WP ON. 

See [MrChromeBox](https://docs.mrchromebox.tech/docs/supported-devices.html) for device specific instructions on how to disable it. 
Then once its disabled, come back here.

**Then, you're done. Boot a shim or whatever.**
Made with ♡ by Cruzy

Pull requests welcome with fixes. 
