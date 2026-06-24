import { useMemo, useState } from "react";

type Tab = "dashboard" | "estrutura" | "raiox" | "candidatos" | "config";
type Wallet = { id: string; categoria: string; pessoa: string; tipo: string; spend: number; afs: number; fornecedores: number; obs: string };
type Person = { id: string; nome: string; cargo: string; cadeira: string; potencial: string; sommos: string; nota: number };
type Skill = { id: string; nome: string; grupo: "Hard" | "Soft" };
type Assessment = { pessoaId: string; skillId: string; esperado: number; atual: number; comentario: string };

const skills: Skill[] = [
  { id: "neg", nome: "Negociacao", grupo: "Hard" },
  { id: "forn", nome: "Gestao de Fornecedores e Stakeholders", grupo: "Hard" },
  { id: "sourcing", nome: "Strategic Sourcing", grupo: "Hard" },
  { id: "ferr", nome: "Ferramentas, sistemas e idiomas", grupo: "Hard" },
  { id: "mercado", nome: "Analise de Mercado e Estrategia de Categoria", grupo: "Hard" },
  { id: "flex", nome: "Flexibilidade e Resiliencia", grupo: "Soft" },
  { id: "com", nome: "Comunicacao de alto impacto", grupo: "Soft" },
  { id: "auto", nome: "Autonomia e Solucao de Problemas", grupo: "Soft" },
  { id: "org", nome: "Organizacao, priorizacao e urgencia", grupo: "Soft" },
  { id: "risco", nome: "Analise de Risco e Tomada de Decisao", grupo: "Soft" },
  { id: "equipe", nome: "Trabalho em Equipe", grupo: "Soft" }
];

const people: Person[] = [
  { id: "bruna", nome: "Bruna Ferreira", cargo: "Analista Pleno", cadeira: "Marketing services e beneficios", potencial: "Especialista", sommos: "Dentro do esperado", nota: 3.5 },
  { id: "pedro", nome: "Pedro Henrique", cargo: "Analista Pleno", cadeira: "Transportes e taxi", potencial: "Analista Senior", sommos: "Em desenvolvimento", nota: 3.1 },
  { id: "joao", nome: "Joao Victor", cargo: "Analista Senior", cadeira: "Frota, locacao e CFTV", potencial: "Consultor I", sommos: "Acima do esperado", nota: 4.1 },
  { id: "gabriel", nome: "Gabriel Menezes", cargo: "Consultor", cadeira: "Alimentacao e gestao", potencial: "Consultor II", sommos: "Dentro do esperado", nota: 3.8 },
  { id: "thais", nome: "Thais Gois", cargo: "Consultor", cadeira: "Limpeza, jardinagem e pragas", potencial: "Referencia tecnica", sommos: "Referencia", nota: 4.6 },
  { id: "tbd", nome: "TBD", cargo: "Analista Senior", cadeira: "Viagens, cafe e documentos", potencial: "Contratacao", sommos: "Abaixo do esperado", nota: 1.8 }
];

const initialWallets: Wallet[] = [
  { id: "cafe", categoria: "CAFE E SNACKS", pessoa: "TBD", tipo: "Rotina", spend: 5997313, afs: 18, fornecedores: 38, obs: "Projeto de Agua Filtrada" },
  { id: "alim", categoria: "FORNECIM ALIM-INDL", pessoa: "Gabriel", tipo: "Rotina", spend: 93991539, afs: 14, fornecedores: 32, obs: "Cachoeiro" },
  { id: "frota", categoria: "FROTA LEVE", pessoa: "Joao", tipo: "Critica", spend: 113446597, afs: 2, fornecedores: 11, obs: "Reajuste 2027" },
  { id: "prop", categoria: "SERV AGENC PROPAGAND", pessoa: "Bruna", tipo: "Projeto", spend: 82913322, afs: 23, fornecedores: 28, obs: "Zerar reajuste de BIDS" },
  { id: "viagem", categoria: "SERV AGENCIAM VIAGEM", pessoa: "TBD", tipo: "Critica", spend: 60896289, afs: 5, fornecedores: 45, obs: "Negociacao Accor" },
  { id: "cartao", categoria: "SERV CARTAO BENEFIC", pessoa: "Bruna", tipo: "Rotina", spend: 142230757, afs: 2, fornecedores: 5, obs: "" },
  { id: "pragas", categoria: "SERV CONTROLE PRAGAS", pessoa: "Thais", tipo: "Rotina", spend: 1745270, afs: 8, fornecedores: 19, obs: "Zerar reajuste" },
  { id: "loc", categoria: "SERV LOC IMOVEL", pessoa: "Joao", tipo: "Critica", spend: 57714823, afs: 21, fornecedores: 33, obs: "" },
  { id: "limpeza", categoria: "SERV LIMPEZA/VIGILANCIA", pessoa: "Thais", tipo: "Critica", spend: 155173138, afs: 60, fornecedores: 68, obs: "Categoria concentrada" },
  { id: "taxi", categoria: "SERV TAXI", pessoa: "Pedro", tipo: "Rotina", spend: 35120000, afs: 24, fornecedores: 21, obs: "" }
];

const initialAssessments: Assessment[] = people.flatMap((p, pi) => skills.map((s, si) => ({ pessoaId: p.id, skillId: s.id, esperado: p.id === "tbd" ? 4 : p.cargo.includes("Consultor") ? 4.3 : p.cargo.includes("Senior") ? 4 : 3, atual: p.id === "tbd" ? 0 : Math.max(1, Math.min(5, (p.cargo.includes("Consultor") ? 3.6 : 2.8) + ((pi + si) % 4) * 0.25)), comentario: "Plano de desenvolvimento no ciclo de 100 dias" })));

const money = (v: number) => new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL", notation: "compact", maximumFractionDigits: 1 }).format(v);

function aggregate(wallets: Wallet[]) {
  return Object.values(wallets.reduce<Record<string, { pessoa: string; spend: number; afs: number; carteiras: number; fornecedores: number }>>((acc, w) => {
    acc[w.pessoa] ??= { pessoa: w.pessoa, spend: 0, afs: 0, carteiras: 0, fornecedores: 0 };
    acc[w.pessoa].spend += w.spend; acc[w.pessoa].afs += w.afs; acc[w.pessoa].carteiras += 1; acc[w.pessoa].fornecedores += w.fornecedores;
    return acc;
  }, {}));
}

function App() {
  const [tab, setTab] = useState<Tab>("dashboard");
  const [wallets, setWallets] = useState(initialWallets);
  const [assessments, setAssessments] = useState(initialAssessments);
  const [person, setPerson] = useState("bruna");
  const [candidateStatus, setCandidateStatus] = useState("Em avaliacao");
  const [comments, setComments] = useState("Hipotese: reduzir concentracao de AFs em limpeza e formalizar sucessor para carteiras criticas.");
  const loads = useMemo(() => aggregate(wallets), [wallets]);
  const totalSpend = wallets.reduce((s, w) => s + w.spend, 0);
  const totalAfs = wallets.reduce((s, w) => s + w.afs, 0);
  const adherence = Math.round(assessments.filter(a => a.atual > 0).reduce((s, a) => s + Math.min(1, a.atual / a.esperado), 0) / assessments.filter(a => a.atual > 0).length * 100);
  const selected = people.find(p => p.id === person) ?? people[0];
  const gaps = assessments.map(a => ({ ...a, pessoa: people.find(p => p.id === a.pessoaId)?.nome ?? "", skill: skills.find(s => s.id === a.skillId)?.nome ?? "", gap: a.esperado - a.atual })).filter(g => g.gap > 0).sort((a,b) => b.gap - a.gap);

  function updateWallet(id: string, field: keyof Wallet, value: string) {
    setWallets(ws => ws.map(w => w.id === id ? { ...w, [field]: ["spend", "afs", "fornecedores"].includes(field) ? Number(value) : value } : w));
  }
  function exportCsv() {
    const rows = wallets.map(w => [w.categoria, w.pessoa, w.tipo, w.spend, w.afs, w.fornecedores, w.obs].join(";"));
    const blob = new Blob([["Categoria;Pessoa;Tipo;Spend;AFs;Fornecedores;Obs", ...rows].join("\n")], { type: "text/csv" });
    const a = document.createElement("a"); a.href = URL.createObjectURL(blob); a.download = "team-os-carteiras.csv"; a.click(); URL.revokeObjectURL(a.href);
  }

  return <div className="shell">
    <aside><div className="brand">Team OS<span>Servicos Corporativos</span></div>{[
      ["dashboard","Dashboard"],["estrutura","Estrutura"],["raiox","Raio X do Time"],["candidatos","Avaliacao de Candidatos"],["config","Configuracoes"]
    ].map(([id,label]) => <button key={id} className={tab===id ? "active" : ""} onClick={() => setTab(id as Tab)}>{label}</button>)}<small>Schema Supabase: team_os</small></aside>
    <main><header><div><p>Align Structure | Plano de 100 dias</p><h1>Servicos Corporativos Team OS</h1></div><button onClick={exportCsv}>Exportar CSV</button></header>
      {tab === "dashboard" && <section className="grid"><Metric label="Pessoas" value={people.length} /><Metric label="Carteiras" value={wallets.length} /><Metric label="Spend" value={money(totalSpend)} /><Metric label="AFs" value={totalAfs} /><Metric label="Aderencia media" value={`${adherence}%`} />
        <Panel title="Spend por pessoa" wide>{loads.map(l => <Bar key={l.pessoa} label={l.pessoa} value={l.spend} max={Math.max(...loads.map(x=>x.spend))} display={money(l.spend)} />)}</Panel>
        <Panel title="AFs por pessoa">{loads.map(l => <Bar key={l.pessoa} label={l.pessoa} value={l.afs} max={Math.max(...loads.map(x=>x.afs))} display={String(l.afs)} />)}</Panel>
        <Panel title="Alertas executivos">{loads.filter(l => l.spend / totalSpend > .25 || l.afs / totalAfs > .25).map(l => <div className="alert" key={l.pessoa}><b>{l.pessoa}</b><span>Concentracao relevante de spend ou AFs. Revisar capacidade, sucessor e redistribuicao.</span></div>)}</Panel>
      </section>}
      {tab === "estrutura" && <section><div className="actions"><button onClick={() => setWallets(ws => [...ws])}>Salvar cenario</button><button onClick={() => setWallets(initialWallets.map(w => ({...w, id: w.id + "-sim"})))}>Duplicar baseline</button></div><Table wallets={wallets} onChange={updateWallet}/></section>}
      {tab === "raiox" && <section className="grid"><Panel title="Pessoa"><select value={person} onChange={e=>setPerson(e.target.value)}>{people.map(p=><option value={p.id} key={p.id}>{p.nome}</option>)}</select><h3>{selected.nome}</h3><p>{selected.cargo}</p><p>{selected.cadeira}</p><p>SOMMOS: {selected.sommos} | Nota {selected.nota}</p></Panel><Panel title="Radar simplificado" wide>{skills.map(s => { const a=assessments.find(x=>x.pessoaId===selected.id&&x.skillId===s.id)!; return <Bar key={s.id} label={s.nome} value={a.atual} max={5} display={`${a.atual.toFixed(1)} / esp. ${a.esperado}`} /> })}</Panel><Panel title="Heatmap" full><div className="heat">{people.map(p=><div key={p.id}><b>{p.nome}</b>{skills.map(s=>{const a=assessments.find(x=>x.pessoaId===p.id&&x.skillId===s.id)!; return <input key={s.id} value={a.atual} type="number" step=".1" min="0" max="5" onChange={e=>setAssessments(as=>as.map(x=>x===a?{...x,atual:Number(e.target.value)}:x))}/>})}</div>)}</div></Panel><Panel title="Maiores gaps" full>{gaps.slice(0,10).map(g=><div className="alert" key={g.pessoa+g.skill}><b>{g.pessoa}</b><span>{g.skill}: gap {g.gap.toFixed(1)}</span></div>)}</Panel></section>}
      {tab === "candidatos" && <section className="grid"><Panel title="Cadastro de candidato"><input defaultValue="Candidato exemplo"/><input defaultValue="Analista Senior"/><select value={candidateStatus} onChange={e=>setCandidateStatus(e.target.value)}>{["Mapeado","Em avaliacao","Entrevistado","Finalista","Aprovado","Reprovado","Banco de talentos"].map(s=><option key={s}>{s}</option>)}</select><textarea defaultValue="Fit cultural, comunicacao, autonomia, capacidade analitica e potencial de crescimento."/></Panel><Panel title="Aderencia a vaga" wide>{skills.map((s,i)=><Bar key={s.id} label={s.nome} value={i%3===0?3:4} max={4} display={i%3===0?"Gap":"Aderente"}/>)}</Panel></section>}
      {tab === "config" && <section className="grid"><Panel title="Supabase"><p>Projeto: wagner-performance-os</p><p>Schema isolado: team_os</p><p>Usar somente publishable/anon key no front-end. Nunca commitar secret key.</p></Panel><Panel title="Comentarios" wide><textarea value={comments} onChange={e=>setComments(e.target.value)}/></Panel></section>}
    </main>
  </div>;
}

function Metric({label,value}:{label:string;value:string|number}){return <article className="metric"><span>{label}</span><b>{value}</b></article>}
function Panel({title,children,wide,full}:{title:string;children:React.ReactNode;wide?:boolean;full?:boolean}){return <section className={`panel ${wide?"wide":""} ${full?"full":""}`}><h2>{title}</h2>{children}</section>}
function Bar({label,value,max,display}:{label:string;value:number;max:number;display:string}){return <div className="bar"><span>{label}</span><div><i style={{width:`${Math.max(4,value/max*100)}%`}} /></div><b>{display}</b></div>}
function Table({wallets,onChange}:{wallets:Wallet[];onChange:(id:string,field:keyof Wallet,value:string)=>void}){return <div className="table"><table><thead><tr><th>Categoria</th><th>Pessoa</th><th>Tipo</th><th>Spend</th><th>AFs</th><th>Fornec.</th><th>Obs</th></tr></thead><tbody>{wallets.map(w=><tr key={w.id}>{(["categoria","pessoa","tipo","spend","afs","fornecedores","obs"] as (keyof Wallet)[]).map(k=><td key={k}><input value={w[k]} type={typeof w[k]==="number"?"number":"text"} onChange={e=>onChange(w.id,k,e.target.value)}/></td>)}</tr>)}</tbody></table></div>}

export default App;
