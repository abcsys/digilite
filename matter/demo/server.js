import fastify from 'fastify';
import fastifyStatic from '@fastify/static';
import cp from 'child_process';
import YAML from 'yaml'
import fs from 'fs/promises';
import * as url from 'url';
import path from 'path';
const __dirname = url.fileURLToPath(new URL('.', import.meta.url));

const EXAMPLES = path.resolve(process.env.EXAMPLES || '~/examples/matter');
const PORT = Number(process.env.PORT || 8080);

function exec(...options) {
  return new Promise(resolve => {
    // Ignore spurious errors
    options.push(resolve)
    cp.exec(...options)
  });
}

const server = fastify({
  logger: true
});

const examples = {
  'lamp': 'lamp'
};

server.register(fastifyStatic, {
  root: path.join(__dirname, 'public/build')
})

server.post('/digi/run/:example', async (request, reply) => {
  const { example } = request.params;
  const { code } = request.body;

  if (!(example in examples)) {
    return reply
      .status(404)
      .send({ ok: false, error: 'Example does not exist yet.' });
  }

  const modelPath = path.join(EXAMPLES, examples[example], 'cr.yaml');

  const model = YAML.parse(await fs.readFile(modelPath, 'utf-8'));
  model.spec.meta.pair_code = code
  await fs.writeFile(modelPath, YAML.stringify(model), 'utf-8');

  await exec(`digi run ${example} m1`, { cwd: EXAMPLES });
});

server.listen(PORT);