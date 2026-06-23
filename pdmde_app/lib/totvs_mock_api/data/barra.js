const { v4: uuidv4 } = require("uuid");

const barras = [
  {
    ID: uuidv4(),
    Linha: 1,
    CodigoMP: "MP-1045-RD50",
    Descricao: "SAE 1045 — Ø50mm",
    Corrida: 10254,
    PesoBarra: 520.0,
    NumeroBarra: "A-001",
    IsRasurada: false,
    Fornecedor: "Aços Villares",
    NumAF: "261544",
  },
  {
    ID: uuidv4(),
    Linha: 2,
    CodigoMP: "MP-1045-RD50",
    Descricao: "SAE 1045 — Ø50mm",
    Corrida: 10254,
    PesoBarra: 498.5,
    NumeroBarra: "A-002",
    IsRasurada: false,
    Fornecedor: "Aços Villares",
    NumAF: "261544",
  },
  {
    ID: uuidv4(),
    Linha: 3,
    CodigoMP: "MP-4140-SX36",
    Descricao: "SAE 4140 — SW36mm",
    Corrida: 10891,
    PesoBarra: 0.0,
    NumeroBarra: "",
    IsRasurada: false,
    Fornecedor: "Gerdau Açominas",
    NumAF: "261545",
  },
];

module.exports = barras;