import { Command } from 'commander';

const program = new Command();
program
    .version('0.0.1')
    .description('Builds extension for use in Fantasy Grounds.')
    .option('-o, --output <value>', 'output directory');

program.parse(process.argv);

const options = program.opts();

console.log(options.output);

build(options.output);

async function build(outputDir: string) {
    const { default: archiver } = await import('archiver');
    const xmlParser = await import('fast-xml-parser');
    const fs = await import('fs');
    const path = await import('path');

    const rawXml = fs.readFileSync(path.resolve(__dirname, 'src/extension.xml')).toString();
    const parsedXml = xmlParser.parse(rawXml);


    const { name, version } = parsedXml.root.properties;

    const fileSafeName = name.replace(/ /g, '_').toLowerCase();

    const outputFileName = `${fileSafeName}_${version}.ext`;

    const outputDirPath = outputDir ? path.resolve(outputDir) : path.resolve(__dirname, 'dist');

    const outputFilePath = path.join(outputDirPath, outputFileName);

    if (!fs.existsSync(outputDirPath)) {
        fs.mkdirSync(outputDirPath, { recursive: true });
    }

    if (fs.existsSync(outputFilePath)) {
        fs.unlinkSync(outputFilePath);
    }

    const outputStream = fs.createWriteStream(outputFilePath)

    const archive = archiver('zip', {
        zlib: { level: 9 },
    });
    archive.pipe(outputStream);

    archive.directory('src', false);

    archive.finalize();
}
