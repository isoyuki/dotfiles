#!/usr/bin/env zx

const modules = {
  awesome: installAwesome,
};

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

main();
