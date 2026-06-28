const express = require("express");
const cors = require("cors");
const { v4: uuidv4 } = require("uuid");
const afs = require("./data/afs");
const produtos = require("./data/produtos");
const barras = require("./data/barras");

const app = express();
app.use(cors());
app.use(express.json());

// AFs

// GET /af  lista todas
app.get("/af", (req, res) => {
  return res.json(afs);
});

// GET /af/:numAF  busca uma
app.get("/af/:numAF", (req, res) => {
  const af = afs.find((a) => a.NumAF === req.params.numAF);
  if (!af) return res.status(404).json({ erro: "AF não encontrada." });
  return res.json(af);
});

// POST /af  cria nova
app.post("/af", (req, res) => {
const { NumAF, Descricao, Fornecedor, PesoTotal, Itens } = req.body;

  if (!NumAF || !Descricao || !Fornecedor || !PesoTotal) {
    return res.status(400).json({ erro: "Campos obrigatórios: NumAF, Descricao, Fornecedor, PesoTotal." });
  }

  const existe = afs.find((a) => a.NumAF === NumAF);
  if (existe) return res.status(409).json({ erro: "AF já cadastrada." });

const nova = { NumAF, Descricao, Fornecedor, PesoTotal, Itens: Itens ?? [] };  afs.push(nova);
  return res.status(201).json(nova);
});

// PUT /af/:numAF  atualiza
app.put("/af/:numAF", (req, res) => {
  const index = afs.findIndex((a) => a.NumAF === req.params.numAF);
  if (index === -1) return res.status(404).json({ erro: "AF não encontrada." });

  afs[index] = { ...afs[index], ...req.body, NumAF: afs[index].NumAF };
  return res.json(afs[index]);
});

// DELETE /af/:numAF  remove
app.delete("/af/:numAF", (req, res) => {
  const index = afs.findIndex((a) => a.NumAF === req.params.numAF);
  if (index === -1) return res.status(404).json({ erro: "AF não encontrada." });

  const removida = afs.splice(index, 1)[0];
  return res.json({ mensagem: "AF removida com sucesso.", af: removida });
});

// BARRAS

// GET /af/:numAF/barras  lista barras da AF
app.get("/af/:numAF/barras", (req, res) => {
  const af = afs.find((a) => a.NumAF === req.params.numAF);
  if (!af) return res.status(404).json({ erro: "AF não encontrada." });

  const barrasAF = barras.filter((b) => b.NumAF === req.params.numAF);
  return res.json(barrasAF);
});

// GET /barras  lista todas
app.get("/barras", (req, res) => {
  return res.json(barras);
});

// GET /barras/:id  busca uma
app.get("/barras/:id", (req, res) => {
  const barra = barras.find((b) => b.ID === req.params.id);
  if (!barra) return res.status(404).json({ erro: "Barra não encontrada." });
  return res.json(barra);
});

// POST /barras  cria nova
app.post("/barras", (req, res) => {
  const { Linha, CodigoMP, Descricao, Corrida, PesoBarra, NumeroBarra, IsRasurada, Fornecedor, NumAF } = req.body;

  if (!Linha || !CodigoMP || !Descricao || !Corrida || !Fornecedor || !NumAF) {
    return res.status(400).json({ erro: "Campos obrigatórios: Linha, CodigoMP, Descricao, Corrida, Fornecedor, NumAF." });
  }

  const nova = {
    ID: uuidv4(),
    Linha,
    CodigoMP,
    Descricao,
    Corrida,
    PesoBarra: PesoBarra ?? 0,
    NumeroBarra: NumeroBarra ?? "",
    IsRasurada: IsRasurada ?? false,
    Fornecedor,
    NumAF,
  };

  barras.push(nova);
  return res.status(201).json(nova);
});

// PUT /barras/:id  
app.put("/barras/:id", (req, res) => {
  const index = barras.findIndex((b) => b.ID === req.params.id);
  if (index === -1) return res.status(404).json({ erro: "Barra não encontrada." });

  barras[index] = { ...barras[index], ...req.body, ID: barras[index].ID };
  return res.json(barras[index]);
});

// DELETE /barras/:id  
app.delete("/barras/:id", (req, res) => {
  const index = barras.findIndex((b) => b.ID === req.params.id);
  if (index === -1) return res.status(404).json({ erro: "Barra não encontrada." });

  const removida = barras.splice(index, 1)[0];
  return res.json({ mensagem: "Barra removida com sucesso.", barra: removida });
});

// PRODUTOS
// GET /produtos  lista todos
app.get("/produtos", (req, res) => {
  return res.json(produtos);
});

// GET /produtos/:codigo  busca um
app.get("/produtos/:codigo", (req, res) => {
  const produto = produtos.find((p) => p.CODIGO === req.params.codigo);
  if (!produto) return res.status(404).json({ erro: "Produto não encontrado." });
  return res.json(produto);
});

// POST /produtos  cria novo
app.post("/produtos", (req, res) => {
  const { CODIGO, DESCRICAO, FORNECEDOR, SaldoDisponivel } = req.body;

  if (!CODIGO || !DESCRICAO || !FORNECEDOR || SaldoDisponivel === undefined) {
    return res.status(400).json({ erro: "Campos obrigatórios: CODIGO, DESCRICAO, FORNECEDOR, SaldoDisponivel." });
  }

  const existe = produtos.find((p) => p.CODIGO === CODIGO);
  if (existe) return res.status(409).json({ erro: "Produto já cadastrado." });

  const novo = { CODIGO, DESCRICAO, FORNECEDOR, SaldoDisponivel };
  produtos.push(novo);
  return res.status(201).json(novo);
});

// PUT /produtos/:codigo  
app.put("/produtos/:codigo", (req, res) => {
  const index = produtos.findIndex((p) => p.CODIGO === req.params.codigo);
  if (index === -1) return res.status(404).json({ erro: "Produto não encontrado." });

  produtos[index] = { ...produtos[index], ...req.body, CODIGO: produtos[index].CODIGO };
  return res.json(produtos[index]);
});

// DELETE /produtos/:codigo  
app.delete("/produtos/:codigo", (req, res) => {
  const index = produtos.findIndex((p) => p.CODIGO === req.params.codigo);
  if (index === -1) return res.status(404).json({ erro: "Produto não encontrado." });

  const removido = produtos.splice(index, 1)[0];
  return res.json({ mensagem: "Produto removido com sucesso.", produto: removido });
});

// ══════════════════════════════════════════════════════
const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`API TOTVS Mock rodando em http://0.0.0.0:${PORT}`);
  console.log(`Também disponível em http://<IP-do-seu-computador>:${PORT}`);
});