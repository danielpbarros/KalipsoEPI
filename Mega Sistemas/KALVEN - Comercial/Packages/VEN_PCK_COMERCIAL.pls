create or replace PACKAGE kalven.VEN_PCK_COMERCIAL IS 
-- Package header

--Movimenta carteira de clientes de acordo com os dias de inatividade
--Clientes sem grupos
procedure P_Movimenta_Carteira_Sem_Grupo;

END;