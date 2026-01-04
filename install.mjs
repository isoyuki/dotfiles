#!/usr/bin/env zx

import { core, dev, github } from "./packages.mjs";

const osPackageManagers = {
  fedora: "dnf",
  arch: "paru",
  ubuntu: "apt",
  macos: "brew",
};

const modules = {
  core: installCore,
  dev: installDev,
  github: installGithub,
  fonts: installFonts,
  alacritty: installAlacritty,
  awesome: installAwesome,
  bash: installBash,
  emacs: installEmacs,
  git: installGit,
  gtk: installGtk,
  nvim: installNvim,
  rofi: installRofi,
  ssh: installSsh,
  systemd: installSystemd,
  tmux: installTmux,
  vim: installVim,
  zsh: installZsh,
};

async function main() {
  const selection = await getSelection();
  const os = argv.os || "fedora";
  await install(selection, os);
}

async function getSelection() {
  let selection = [];

  if (argv._.length > 0) {
    selection = argv._;
  } else {
    const response = await question("Which modules do you want to install? (all) ", {
      choices: Object.keys(modules),
    });
    selection = response.split(" ");
  }

  if (selection.includes("all")) {
    selection = Object.keys(modules);
  }

  return selection;
}

async function install(selection, os) {
  for (const module of selection) {
    if (modules[module]) {
      await modules[module](os);
    } else {
      console.log(`Module ${module} not found.`);
    }
  }
}

async function installCore(os) {
  console.log("Installing core packages...");
  const packageManager = osPackageManagers[os];
  if (!packageManager) {
    console.error(`Unsupported OS: ${os}`);
    return;
  }
  try {
    if (packageManager === "dnf") {
      await $`sudo ${packageManager} install -y ${core.join(" ")}`;
    } else {
      await $`${packageManager} -S --needed ${core.join(" ")}`;
    }
  } catch (error) {
    console.error("Failed to install core packages:", error);
  }
}

async function installDev(os) {
  console.log("Installing dev packages...");
  const packageManager = osPackageManagers[os];
  if (!packageManager) {
    console.error(`Unsupported OS: ${os}`);
    return;
  }
  try {
    if (packageManager === "dnf") {
      await $`sudo ${packageManager} install -y ${dev.join(" ")}`;
    } else {
      await $`${packageManager} -S --needed ${dev.join(" ")}`;
    }
  } catch (error) {
    console.error("Failed to install dev packages:", error);
  }
}

async function installGithub() {
  console.log("Installing github packages...");
  const installDir = path.join(os.homedir(), ".local", "src");
  await fs.ensureDir(installDir);

  for (const [name, url] of Object.entries(github)) {
    console.log(`Installing ${name} from ${url}...`);
    const repoDir = path.join(installDir, name);
    if (await fs.pathExists(repoDir)) {
      console.log(`${name} is already cloned. Pulling latest changes...`);
      await $`git -C ${repoDir} pull`;
    } else {
      await $`git clone ${url} ${repoDir}`;
    }

    if (name === "picom") {
      const buildDir = path.join(repoDir, "build");
      if (await fs.pathExists(buildDir)) {
        console.log("picom is already built. Skipping build and install.");
      } else {
        await $`git -C ${repoDir} submodule update --init --recursive`;
        await $`meson --buildtype=release . build`;
        await $`ninja -C build`;
        await $`sudo ninja -C build install`;
      }
    }
  }
}

async function installFonts() {
  console.log("Installing fonts...");
  const sourceDir = path.join(process.cwd(), "fonts", ".fonts");
  const targetDir = path.join(os.homedir(), ".local", "share", "fonts");

  await fs.ensureDir(targetDir);
  await $`cp -r ${sourceDir}/* ${targetDir}`;
  await $`fc-cache -f -v`;
}

async function installModule(name, source, target) {
    console.log(`Installing ${name}...`);
    const installScript = path.join(process.cwd(), name, "install.sh");
    if (await fs.pathExists(installScript)) {
        await $`bash ${installScript}`;
    } else {
        await fs.ensureDir(target);
        const files = await fs.readdir(source);
        for (const file of files) {
            const sourcePath = path.join(source, file);
            const targetPath = path.join(target, file);
            await $`ln -sf ${sourcePath} ${targetPath}`;
        }
    }
}

async function installAlacritty() {
    await installModule(
        "alacritty",
        path.join(process.cwd(), "alacritty", ".config", "alacritty"),
        path.join(os.homedir(), ".config", "alacritty")
    );
}

async function installAwesome() {
    await installModule(
        "awesome",
        path.join(process.cwd(), "awesome", ".config", "awesome"),
        path.join(os.homedir(), ".config", "awesome")
    );
}

async function installBash() {
    await installModule(
        "bash",
        path.join(process.cwd(), "bash"),
        os.homedir()
    );
}

async function installEmacs() {
    await installModule(
        "emacs",
        path.join(process.cwd(), "emacs", ".config", "doom"),
        path.join(os.homedir(), ".config", "doom")
    );
}

async function installGit() {
    await installModule(
        "git",
        path.join(process.cwd(), "git"),
        os.homedir()
    );
}

async function installGtk() {
    await installModule(
        "gtk",
        path.join(process.cwd(), "gtk", ".config"),
        path.join(os.homedir(), ".config")
    );
}

async function installNvim() {
    await installModule(
        "nvim",
        path.join(process.cwd(), "nvim", ".config", "nvim"),
        path.join(os.homedir(), ".config", "nvim")
    );
}

async function installRofi() {
    await installModule(
        "rofi",
        path.join(process.cwd(), "rofi", ".config", "rofi"),
        path.join(os.homedir(), ".config", "rofi")
    );
}

async function installSsh() {
    await installModule(
        "ssh",
        path.join(process.cwd(), "ssh", ".ssh"),
        path.join(os.homedir(), ".ssh")
    );
}

async function installSystemd() {
    await installModule(
        "systemd",
        path.join(process.cwd(), "systemd", ".config", "systemd"),
        path.join(os.homedir(), ".config", "systemd")
    );
}

async function installTmux() {
    await installModule(
        "tmux",
        path.join(process.cwd(), "tmux", ".config", "tmux"),
        path.join(os.homedir(), ".config", "tmux")
    );
}

async function installVim() {
    await installModule(
        "vim",
        path.join(process.cwd(), "vim"),
        os.homedir()
    );
}

async function installZsh() {
    await installModule(
        "zsh",
        path.join(process.cwd(), "zsh"),
        os.homedir()
    );
}

main();