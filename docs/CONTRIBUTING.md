# Fluxo de contribuição

## Branches (Git Flow)

- `main`: versões estáveis, identificadas por tags `vX.Y.Z`.
- `develop`: integração das alterações destinadas à próxima versão.
- `feature/<issue>-<descricao>`: tarefas criadas de `develop`.
- `release/<versao>`: preparação de uma versão, criada de `develop`.
- `hotfix/<issue>-<descricao>`: correções urgentes criadas de `main`.

Use descrições curtas, em minúsculas e separadas por hífens. Integre alterações
em `main` e `develop` por Pull Requests (PRs). A criação inicial de `develop`
a partir de `main` é o bootstrap do fluxo. A extensão `git-flow` é opcional;
os comandos Git padrão são suficientes.

## Implementar uma issue

Com a árvore de trabalho limpa, atualize `develop` e crie uma feature:

```sh
git fetch origin
git switch develop
git pull --ff-only origin develop
git switch -c feature/1-estrutura-inicial
```

Faça alterações focadas na issue e valide os componentes afetados. Enquanto
não houver código executável, revise documentação, links e regras do
`.gitignore`. Quando existirem testes e verificações automatizadas, execute-os
antes de abrir o PR e registre os resultados na descrição.

```sh
git add README.md .gitignore game/ backend/ docs/
git commit -m "chore: configura estrutura inicial (#1)"
git push -u origin feature/1-estrutura-inicial
```

Adapte o número, a descrição da branch e os arquivos ao trabalho realizado.

## Pull Requests

1. Abra o PR de `feature/*` para `develop`.
2. Informe o problema, as mudanças, os passos de validação e limitações.
3. Referencie a issue com `Refs #1`. Use `Closes #1` no PR da release para
   `main`, ou feche a issue manualmente após a entrega.
4. Solicite revisão de outro colaborador, quando disponível. Resolva os
   comentários e conflitos; as verificações existentes devem passar.
5. Integre com **merge commit**, preservando o histórico da branch. Após o
   merge, a branch de feature pode ser removida.

Essas são convenções do projeto. Proteções de branch e verificações obrigatórias
precisam ser configuradas separadamente no GitHub quando disponíveis.

## Releases e correções urgentes

Crie `release/<versao>` de `develop` quando o escopo da versão estiver pronto.
Finalize documentação, versão e correções de estabilização. Abra um PR para
`main`, valide e integre com merge commit. Marque o commit resultante em `main`
com a tag `vX.Y.Z` e publique a tag. Depois, abra um PR de `main` para `develop`
para incorporar as alterações de estabilização.

Para um hotfix, crie `hotfix/<issue>-<descricao>` de `main`, implemente e valide
a correção e abra um PR para `main`. Após o merge, publique uma nova tag de
correção e abra um PR de `main` para `develop`. Incorpore a correção também em
uma release em andamento, se houver, antes de publicá-la.
