create or replace PACKAGE BODY KALVEN.VEN_PCK_COMERCIAL AS

  procedure P_Movimenta_Carteira_Sem_Grupo AS
  
  --variaveis
  
  --cursor
  cursor cMVA is
  SELECT CLI_IN_CODIGO
      ,CLI_TAB_IN_CODIGO
      ,CLI_PAD_IN_CODIGO
      ,CLI_ST_CGC
      ,CLI_ST_NOME
      ,CLI_ST_FANTASIA
      ,CLI_ST_CEP
      ,CLI_ST_LOGRADOURO
      ,CLI_ST_BAIRRO
      ,CLI_ST_MUNICIPIO
      ,CLI_ST_NUMERO
      ,CLI_ST_COMPLEMENTO
      ,CLI_ST_UF
      ,REP_IN_CODIGO
      ,REP_ST_NOME
      ,REP_ST_EMAIL
      ,VEN_IN_CODIGO
      ,VEN_ST_FANTASIA
      ,VEN_ST_EMAIL
      ,NF_DT_ULTIMACOMPRA
      ,GCR_ST_CODIGO
      ,GCR_ST_DESCRICAO
      ,AGN_CH_STATUS
      ,DIAS
      ,MOVECARTEIRA
  FROM(
SELECT CLI_IN_CODIGO
      ,CLI_TAB_IN_CODIGO
      ,CLI_PAD_IN_CODIGO
      ,CLI_ST_CGC
      ,CLI_ST_NOME
      ,CLI_ST_FANTASIA
      ,CLI_ST_CEP
      ,CLI_ST_LOGRADOURO
      ,CLI_ST_BAIRRO
      ,CLI_ST_MUNICIPIO
      ,CLI_ST_NUMERO
      ,CLI_ST_COMPLEMENTO
      ,CLI_ST_UF
      ,REP_IN_CODIGO
      ,REP_ST_NOME
      ,REP_ST_EMAIL
      ,VEN_IN_CODIGO
      ,VEN_ST_FANTASIA
      ,VEN_ST_EMAIL
      ,NF_DT_ULTIMACOMPRA
      ,GCR_ST_CODIGO
      ,GCR_ST_DESCRICAO
      ,AGN_CH_STATUS
      ,TRUNC(SYSDATE) - NF_DT_ULTIMACOMPRA AS DIAS
      ,CASE 
        WHEN (CLI_ST_UF IN ('BA','MA','PI','CE','RN','PB','PE','AL','SE','AM','PA','AC','RR','RO','AP','TO')) AND (TRUNC(SYSDATE) - NF_DT_ULTIMACOMPRA > 120) THEN 'X'
        WHEN (CLI_ST_UF NOT IN ('BA','MA','PI','CE','RN','PB','PE','AL','SE','AM','PA','AC','RR','RO','AP','TO')) AND (TRUNC(SYSDATE) - NF_DT_ULTIMACOMPRA > 90) THEN 'X'
       END AS MOVECARTEIRA
  FROM(
SELECT CLI.AGN_IN_CODIGO      AS CLI_IN_CODIGO
      ,CLI.AGN_TAB_IN_CODIGO  AS CLI_TAB_IN_CODIGO
      ,CLI.AGN_PAD_IN_CODIGO  AS CLI_PAD_IN_CODIGO
      ,CLI.AGN_ST_CGC         AS CLI_ST_CGC
      ,CLI.AGN_ST_NOME        AS CLI_ST_NOME
      ,CLI.AGN_ST_FANTASIA    AS CLI_ST_FANTASIA
      ,CLI.AGN_ST_CEP         AS CLI_ST_CEP
      ,CLI.AGN_ST_LOGRADOURO  AS CLI_ST_LOGRADOURO
      ,CLI.AGN_ST_BAIRRO      AS CLI_ST_BAIRRO
      ,MUN.MUN_ST_NOME        AS CLI_ST_MUNICIPIO
      ,CLI.AGN_ST_NUMERO      AS CLI_ST_NUMERO
      ,CLI.AGN_ST_COMPLEMENTO AS CLI_ST_COMPLEMENTO
      ,CLI.UF_ST_SIGLA        AS CLI_ST_UF
      ,REP.AGN_IN_CODIGO      AS REP_IN_CODIGO
      ,REP.AGN_ST_FANTASIA    AS REP_ST_NOME
      ,REP.AGN_ST_EMAIL       AS REP_ST_EMAIL
      ,VEN.AGN_IN_CODIGO      AS VEN_IN_CODIGO
      ,VEN.AGN_ST_FANTASIA    AS VEN_ST_FANTASIA
      ,VEN.AGN_ST_EMAIL       AS VEN_ST_EMAIL
      ,(SELECT MAX(NF.NOT_DT_EMISSAO)
         FROM DBKAL.VEN_NOTAFISCAL NF
        WHERE NF.AGN_TAB_IN_CODIGO = CLI.AGN_TAB_IN_CODIGO
          AND NF.AGN_PAD_IN_CODIGO = CLI.AGN_PAD_IN_CODIGO
          AND NF.AGN_IN_CODIGO     = CLI.AGN_IN_CODIGO
          --
          AND NF.ACAO_IN_CODIGO = 620
          AND NF.NOT_CH_SITUACAO   <> 'C') AS NF_DT_ULTIMACOMPRA
      ,GT.GCR_ST_CODIGO
      ,NVL(GT.GCR_ST_DESCRICAO,'**Sem Grupo**') AS GCR_ST_DESCRICAO
      ,AGI.AGN_CH_STATUS
     
  FROM DBKAL.GLO_AGENTES_ID AGI
      ,DBKAL.GLO_AGENTES CLI
      ,DBKAL.GLO_MUNICIPIO MUN
      ,DBKAL.GLO_RELACAO_CLI_REP RCR
      ,DBKAL.GLO_AGENTES REP
      ,DBKAL.GLO_AGENTECAMPOESPECIFICO ACE
      ,DBKAL.GLO_AGENTES VEN
      ,DBKAL.VEN_AGENTESGRUPO AG
      ,DBKAL.VEN_GRUPOCREDITO GT
 WHERE AGI.AGN_TAB_IN_CODIGO = CLI.AGN_TAB_IN_CODIGO 
   AND AGI.AGN_PAD_IN_CODIGO = CLI.AGN_PAD_IN_CODIGO 
   AND AGI.AGN_IN_CODIGO    = CLI.AGN_IN_CODIGO 
   --
   AND CLI.MUN_IN_CODIGO     = MUN.MUN_IN_CODIGO 
   AND CLI.UF_ST_SIGLA       = MUN.UF_ST_SIGLA 
   --
   AND CLI.AGN_TAB_IN_CODIGO = RCR.CLI_TAB_IN_CODIGO(+) 
   AND CLI.AGN_PAD_IN_CODIGO = RCR.CLI_PAD_IN_CODIGO(+) 
   AND CLI.AGN_IN_CODIGO    = RCR.CLI_AGN_IN_CODIGO(+) 
   --
   AND RCR.REP_TAB_IN_CODIGO = REP.AGN_TAB_IN_CODIGO(+) 
   AND RCR.REP_PAD_IN_CODIGO = REP.AGN_PAD_IN_CODIGO(+) 
   AND RCR.REP_AGN_IN_CODIGO = REP.AGN_IN_CODIGO(+) 
   --
   AND CLI.AGN_TAB_IN_CODIGO = ACE.AGN_TAB_IN_CODIGO(+)
   AND CLI.AGN_PAD_IN_CODIGO = ACE.AGN_PAD_IN_CODIGO(+)
   AND CLI.AGN_IN_CODIGO     = ACE.AGN_IN_CODIGO(+)
   --
   AND ACE.COD_REPRESENTANTE_INTERNO = VEN.AGN_IN_CODIGO(+)
   --
   AND CLI.AGN_TAB_IN_CODIGO    = AG.AGN_TAB_IN_CODIGO(+)
   AND CLI.AGN_PAD_IN_CODIGO    = AG.AGN_PAD_IN_CODIGO(+)
   AND CLI.AGN_IN_CODIGO        = AG.AGN_IN_CODIGO(+)
   --
   AND AG.GCR_TAB_IN_CODIGO     = GT.GCR_TAB_IN_CODIGO(+)
   AND AG.GCR_PAD_IN_CODIGO     = GT.GCR_PAD_IN_CODIGO(+)
   AND AG.GCR_ST_CODIGO         = GT.GCR_ST_CODIGO(+)
   --
   AND AGI.AGN_TAU_ST_CODIGO = 'C')  --> APENAS CLIENTES
WHERE NF_DT_ULTIMACOMPRA IS NOT NULL --> TRATA CLIENTE QUE NÃO APRESENTAM NOTAS FISCAIS DE COMPRAS
  AND GCR_ST_CODIGO IS NULL)         --> APENAS CLIENTES SEM GRUPOS VINCULADOS
WHERE MOVECARTEIRA = 'X'             --> APENAS CLIENTES INATIVOS COMERCIALMENTE
  AND AGN_CH_STATUS = 'A'            --> APENAS CLIENTES ATIVOS DE CADASTRO
ORDER BY 1;

  BEGIN
    
    for x in cMVA loop 
     --> Insere registro na tabela de histórico de movimentação de carteira
     insert into kalven.ven_movcarteira (mca_in_codigo,
                                         cli_tab_in_codigo,
                                         cli_pad_in_codigo,
                                         cli_in_codigo,
                                         rep_in_codigo_old,
                                         ven_in_codigo_old,
                                         rep_in_codigo_new,
                                         ven_in_codigo_new,
                                         mca_dt_ultimacompra,
                                         mca_dt_movimento)
                                  values (kalven.seq_ven_movcarteira.nextval,
                                          x.cli_tab_in_codigo,
                                          x.cli_pad_in_codigo,
                                          x.cli_in_codigo,
                                          x.rep_in_codigo,
                                          x.ven_in_codigo,
                                          1098, --> nao ha representante
                                          8769, --> nao ha vendedor
                                          x.nf_dt_ultimacompra,
                                          sysdate);
                                          
     --> Atualiza tabela que vincula representante x cliente: dbkal.glo_relacao_cli_rep
     update dbkal.glo_relacao_cli_rep 
        set rep_agn_in_codigo = 1098
      where cli_agn_in_codigo = x.cli_in_codigo
        and cli_tab_in_codigo = x.cli_tab_in_codigo
        and cli_pad_in_codigo = x.cli_pad_in_codigo
        and cli_tau_st_codigo = 'C'
        and rep_tau_st_codigo = 'R'
        and agn_ch_status     = 'A';--14547
     
    --> Atualiza tabela de vincula vendedor interno x cliente: dbkal.GLO_AGENTESCMPESP
    update dbkal.GLO_AGENTESCMPESP
       set REP_IN_CODINT = 8769
     where agn_tab_in_codigo = x.cli_tab_in_codigo
       and agn_pad_in_codigo = x.cli_pad_in_codigo
       and agn_in_codigo     = x.cli_in_codigo;
       
    commit; --> commit update vendedor
       
    end loop;
                                              
  END P_Movimenta_Carteira_Sem_Grupo;

END VEN_PCK_COMERCIAL;
