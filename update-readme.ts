import { readFile, writeFile, readdir, stat } from "node:fs/promises";
import { join } from "node:path";

const nvimPluginDir = join(Bun.env.HOME, ".local", "share", "nvim", "lazy");
const files = await readdir(nvimPluginDir);
const directories = await Promise.all(
	files
		.map(async fileName => {
			const fileStats = await stat(join(nvimPluginDir, fileName));
			return fileStats.isDirectory() ? fileName : null;
		})
		.filter(fileName => fileName !== null)
);
directories.sort();

const gitRemotes = (
	await Promise.all(
		directories.map(async directory => {
			try {
				const gitConfigPath = join(nvimPluginDir, directory, ".git", "config");
				const configContent = await readFile(gitConfigPath, "utf-8");
				const match = configContent.match(/\[remote "origin"\][\s\S]*?url = (.+)/);
				return { name: directory, url: match ? match[1] : null };
			} catch (err) {
				return null;
			}
		})
	)
).filter(({ name, url }) => url !== null && !["lazy.nvim", "LazyVim"].includes(name));

const pluginList = gitRemotes.map(({ name, url }) => `- [${name}](${url})`);

const readmePath = join(".", "README.md");
const readmeContent = await readFile(readmePath, "utf-8");
const lines = readmeContent.split("\n");
const pluginsHeaderIndex = lines.findIndex(line => line.match(/^### Neovim Plugins/));
if (pluginsHeaderIndex === -1) {
	throw new Error("Could not find '### Neovim Plugins' header in README.md");
}
const newContent = lines.slice(0, pluginsHeaderIndex);
newContent.push(`### Neovim Plugins (${pluginList.length})`);
newContent.push(pluginList.join("\n"));
await writeFile(readmePath, newContent.join("\n"), "utf-8");
console.log("README.md has been updated successfully.");
