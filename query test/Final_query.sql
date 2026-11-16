CREATE OR REPLACE VIEW vw_programa_beneficio AS (
	WITH cte_incidentes AS (
	    SELECT
			*,
	        inc.ts_fechamento AS data_fechamento,
	        LAG(ts_fechamento) OVER (PARTITION BY nr_bem ORDER BY ts_chamado) AS lag_day,
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
	    crm.cd_defeito,
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
	    inc.lag_day,
	    inc.data_final,
	    LEAD(ts_chamado::date - lag_day::date) OVER (PARTITION BY nr_bem ORDER BY ts_chamado) AS diff_days
	FROM geral.tb_crm crm
	INNER JOIN cte_incidentes inc
	    ON crm.nr_solicitacao_servico = inc.nr_incidente
	WHERE inc.ts_fechamento BETWEEN DATE '2026-06-30' AND inc.data_final
		AND ts_chamado > '2025-12-30'
		AND nm_status_tarefa = 'Concluído'
	ORDER BY data_abertura, lag_day
);
--DROP VIEW IF EXISTS vw_programa_beneficio;
SELECT 
	nr_bem,
	cd_tarefa,
	nm_tecnico,
	nm_status_tarefa,
	cd_defeito,
	nr_incidente,
	data_abertura,
	data_fechamento::date,
	data_final,
	lag_day::date,
	diff_days
FROM vw_programa_beneficio
WHERE nr_bem = '7417183021954';--'7417163283353', '7417231861697';


--=============================
-- Incidentes repetidos
--=============================
SELECT
	nr_incidente,
	nr_bem,
	count(*)
FROM vw_programa_beneficio
GROUP BY nr_incidente, nr_bem
HAVING count(*) > 1
ORDER BY nr_incidente;

--=============================
-- null nm_tecnico/matricula
--=============================
SELECT
	nr_bem, --incidente
	nr_solicitacao_servico -- crm
FROM vw_programa_beneficio
WHERE nr_matricula IS null
		AND nm_tecnico IS NULL;
