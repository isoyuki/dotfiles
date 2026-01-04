#!/usr/bin/env zx

import { core, dev } from "./packages.mjs";

import { core, dev, github } from "./packages.mjs";

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

async function installFonts() {
  console.log("Installing fonts...");
  const sourceDir = path.join(process.cwd(), "fonts", ".fonts");
  const targetDir = path.join(os.homedir(), ".local", "share", "fonts");

  await fs.ensureDir(targetDir);
  await $`cp -r ${sourceDir}/* ${targetDir}`;
  await $`fc-cache -f -v`;
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
      await $`git -C ${repoDir} submodule update --init --recursive`;
      await $`meson --buildtype=release . build`;
      await $`ninja -C build`;
      await $`sudo ninja -C build install`;
    }
  }
}

async function installCore() {
  console.log("Installing core packages...");
  try {
    await $`paru -S --needed ${core.join(" ")}`;
  } catch (error) {
    console.error("Failed to install core packages:", error);
  }
}

async function installDev() {
  console.log("Installing dev packages...");
  try {
    await $`paru -S --needed ${dev.join(" ")}`;
  } catch (error) {
    console.error("Failed to install dev packages:", error);
  }
}

async function main() {
  const selection = await getSelection();
  await install(selection);
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

async function install(selection) {
  for (const module of selection) {
    if (modules[module]) {
      await modules[module]();
    } else {
      console.log(`Module ${module} not found.`);
    }
  }
}

async function installAlacritty() {
    console.log("Installing alacritty...");
    const sourceDir = path.join(process.cwd(), "alacritty", ".config", "alacritty");
    const targetDir = path.join(os.homedir(), ".config", "alacritty");

    await fs.ensureDir(targetDir);

    const files = await fs.readdir(sourceDir);
    for (const file of files) {
        const source = path.join(sourceDir, file);
        const target = path.join(targetDir, file);
        await $`ln -sf ${source} ${target}`;
    }
}

async function installAwesome() {
  console.log("Installing awesome...");
  const sourceDir = path.join(process.cwd(), "awesome", ".config", "awesome");
  const targetDir = path.join(os.homedir(), ".config", "awesome");

  await fs.ensureDir(targetDir);

  const files = await fs.readdir(sourceDir);
  for (const file of files) {
    const source = path.join(sourceDir, file);
    const target = path.join(targetDir, file);
    await $`ln -sf ${source} ${target}`;
  }
}

async function installBash() {
    console.log("Installing bash...");
    const sourceDir = path.join(process.cwd(), "bash");
    const targetDir = os.homedir();

    const files = await fs.readdir(sourceDir);
    for (const file of files) {
        const source = path.join(sourceDir, file);
        const target = path.join(targetDir, file);
        await $`ln -sf ${source} ${target}`;
    }
}

async function installEmacs() {
    console.log("Installing emacs...");
    const sourceDir = path.join(process.cwd(), "emacs", ".config", "doom");
    const targetDir = path.join(os.homedir(), ".config", "doom");

    await fs.ensureDir(targetDir);

    const files = await fs.readdir(sourceDir);
    for (const file of files) {
        const source = path.join(sourceDir, file);
        const target = path.join(targetDir, file);
        await $`ln -sf ${source} ${target}`;
    }
}

async function installGit() {
    console.log("Installing git...");
    const source = path.join(process.cwd(), "git", ".gitconfig");
    const target = path.join(os.homedir(), ".gitconfig");
    await $`ln -sf ${source} ${target}`;
}

async function installGtk() {
    console.log("Installing gtk...");
    const sourceDir = path.join(process.cwd(), "gtk", ".config");
    const targetDir = path.join(os.homedir(), ".config");

    await fs.ensureDir(targetDir);

    const files = await fs.readdir(sourceDir);
    for (const file of files) {
        if (file.startsWith("gtk-")) {
            const source = path.join(sourceDir, file);
            const target = path.join(targetDir, file);
            await $`ln -sf ${source} ${target}`;
        }
    }
}

async function installNvim() {
    console.log("Installing nvim...");
    const sourceDir = path.join(process.cwd(), "nvim", ".config", "nvim");
    const targetDir = path.join(os.homedir(), ".config", "nvim");

    await fs.ensureDir(targetDir);

    const files = await fs.readdir(sourceDir);
    for (const file of files) {
        const source = path.join(sourceDir, file);
        const target = path.join(targetDir, file);
        await $`ln -sf ${source} ${target}`;
    }
}

async function installRofi() {
    console.log("Installing rofi...");
    const sourceDir = path.join(process.cwd(), "rofi", ".config", "rofi");
    const targetDir = path.join(os.homedir(), ".config", "rofi");

    await fs.ensureDir(targetDir);

    const files = await fs.readdir(sourceDir);
    for (const file of files) {
        const source = path.join(sourceDir, file);
        const target = path.join(targetDir, file);
        await $`ln -sf ${source} ${target}`;
    }
}

async function installSsh() {
    console.log("Installing ssh...");
    const sourceDir = path.join(process.cwd(), "ssh", ".ssh");
    const targetDir = path.join(os.homedir(), ".ssh");

    await fs.ensureDir(targetDir);

    const files = await fs.readdir(sourceDir);
    for (const file of files) {
        const source = path.join(sourceDir, file);
        const target = path.join(targetDir, file);
        await $`ln -sf ${source} ${target}`;
    }
}

async function installSystemd() {
    console.log("Installing systemd...");
    const sourceDir = path.join(process.cwd(), "systemd", ".config", "systemd");
    const targetDir = path.join(os.homedir(), ".config", "systemd");

    await fs.ensureDir(targetDir);

    const files = await fs.readdir(sourceDir);
    for (const file of files) {
        const source = path.join(sourceDir, file);
        const target = path.join(targetDir, file);
        await $`ln -sf ${source} ${target}`;
    }
}

async function installTmux() {
    console.log("Installing tmux...");
    const sourceDir = path.join(process.cwd(), "tmux", ".config", "tmux");
    const targetDir = path.join(os.homedir(), ".config", "tmux");

    await fs.ensureDir(targetDir);

    const files = await fs.readdir(sourceDir);
    for (const file of files) {
        const source = path.join(sourceDir, file);
        const target = path.join(targetDir, file);
        await $`ln -sf ${source} ${target}`;
    }
}

async function installVim() {
    console.log("Installing vim...");
    const source = path.join(process.cwd(), "vim", ".vim");
    const target = path.join(os.homedir(), ".vim");
    await $`ln -sf ${source} ${target}`;
}

async function installZsh() {
    console.log("Installing zsh...");
    const sourceDir = path.join(process.cwd(), "zsh");
    const targetDir = os.homedir();

    const files = await fs.readdir(sourceDir);
    for (const file of files) {
        if (file === ".zshrc") {
            const source = path.join(sourceDir, file);
            const target = path.join(targetDir, file);
            await $`ln -sf ${source} ${target}`;
        }
    }

    const sourceOhMyZsh = path.join(process.cwd(), "zsh", ".config", "oh-my-zsh");
    const targetOhMyZsh = path.join(os.homedir(), ".config", "oh-my-zsh");
    await $`ln -sf ${sourceOhMyZsh} ${targetOhMyZsh}`;
}

main();
