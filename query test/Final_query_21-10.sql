CREATE OR REPLACE VIEW vw_programa_beneficio AS (
	WITH cte_incidentes AS (
	    SELECT
			*,
	        inc.ts_fechamento AS data_fechamento,
	        FIRST_VALUE((ts_fechamento + INTERVAL '6 months')::date) OVER (PARTITION BY nr_bem ORDER BY ts_fechamento) AS data_final
	    FROM geral.tb_incidentes inc
	    WHERE inc.nr_contrato = '00657/2026'
	      AND UPPER(inc.tp_atendimento) = 'MANUTENÇÃO CORRETIVA'
	)
	SELECT
		inc.nr_incidente,
		crm.cd_tarefa,
		crm.nr_tarefa,
		inc.nr_os,
	    inc.nr_bem,
	    inc.ds_bem,
	    crm.ds_tipo_equipamento,
	    inc.ds_defeito,
	    inc.tp_atendimento,
	    inc.nr_criticidade,
	    inc.ds_status,
	    crm.nr_solicitacao_servico,
	    crm.nm_tecnico,
	    crm.nr_matricula,
	    crm.nm_status_tarefa,
	    crm.cd_solucao,
	    crm.ds_solucao,
	    crm.ds_observacao_solucao,
	    inc.ds_fornecedor,
	    inc.nm_cidade,
	    inc.sg_uf,
	    inc.ts_chamado::date AS data_abertura,
	    inc.data_fechamento,
	    inc.data_final,
        LEAD(ts_fechamento) OVER (PARTITION BY nr_bem ORDER BY ts_fechamento, cd_tarefa) AS lead_day
	FROM geral.tb_crm crm
	INNER JOIN cte_incidentes inc
	    ON crm.nr_solicitacao_servico = inc.nr_incidente
	WHERE inc.ts_fechamento BETWEEN DATE '2026-06-30' AND inc.data_final
);

SELECT * FROM vw_programa_beneficio
WHERE nr_bem = '7417161480040';