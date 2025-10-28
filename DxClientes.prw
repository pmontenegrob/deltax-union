#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "aarray.CH"
#Include "json.ch"
#INCLUDE "RESTFUL.CH"

WSRESTFUL dxclientes DESCRIPTION "Clientes Delta X"

	//WSDATA limit      AS INTEGER
	//WSDATA offset     AS INTEGER
	//WSDATA code  AS STRING
	WSMETHOD GET DESCRIPTION "Clientes Delta" WSSYNTAX "/dxclientes"

END WSRESTFUL

WSMETHOD GET WSRECEIVE limit, offset, code WSSERVICE dxclientes
	LOCAL aClientes := {}
	local objClientes
	

	::SetContentType("application/json;charset=utf-8")

	OrdenConsul	:= GetNextAlias()
	
	//cTipoCli :=	"%%" // filtro por tipo de producto
	//cCliCode :="%%" // codigo de producto
	

	/*if !empty(::code)
		cCliCode := "% and (SA1.A1_COD+ SA1.A1_LOJA )= '"+ ::code +"' %"

	endif*/



	BeginSql Alias OrdenConsul
		select A1_COD AS CODIGO_CLIENTE ,
		A1_NREDUZ AS NOM_FANT,
		A1_UCELULA AS CELULAR,
		A1_END AS DIRECCION,
		A1_EMAIL AS EMAIL,
		A1_UCMFEC AS F_MODIFICACION,
		CASE 
		WHEN SA1.A1_MSBLQL ='1'  THEN 'Inactivo' 
		WHEN SA1.A1_MSBLQL ='2'  THEN 'Activo'  
		ELSE 'Sin asignar'END as ESTADO,
		CASE 
		WHEN SA1.A1_UCTIPO ='1'  THEN 'DGAN' 
		WHEN SA1.A1_UCTIPO ='2'  THEN 'DIN' 
		WHEN SA1.A1_UCTIPO ='3'  THEN 'PETS'
		WHEN SA1.A1_UCTIPO ='4'  THEN 'DACER' 
		WHEN SA1.A1_UCTIPO ='5'  THEN 'ECOM' 
		ELSE 'Sin asignar'
		END AS BASE_CLIENTE,
		Z20_PROVIN AS PROVINCIA,
		Z20_MUNICI AS MUNICIPIO,
		Z20_DEPART AS DEPARTAMENTO,
		A1_UCRMLAT AS LATITUD,
		A1_UCRMLON AS LONGITUD
		from SA1010 SA1
		LEFT JOIN SA3010 A3 ON A3.D_E_L_E_T_ != '*' AND SA1.A1_VEND = A3.A3_COD
		LEFT JOIN CTT010 CTT ON CTT.D_E_L_E_T_ != '*' AND SA1.A1_UCCC = CTT.CTT_CUSTO
		LEFT JOIN SE4010 SE4 ON SE4.D_E_L_E_T_ != '*' AND SA1.A1_COND = SE4.E4_CODIGO
		LEFT JOIN DA0010 DA0 ON DA0.D_E_L_E_T_ != '*' AND SA1.A1_TABPADR = DA0.DA0_CODTAB AND DA0.DA0_FILIAL = '0105'
		LEFT JOIN Z20010 Z20 ON Z20.D_E_L_E_T_ != '*' AND SA1.A1_COD_MUN = Z20.Z20_COD
		LEFT JOIN SX5010 SX5 ON SX5.D_E_L_E_T_ != '*' AND SA1.A1_TIPO = SX5.X5_CHAVE AND SX5.X5_TABELA ='1T'
		where SA1.A1_LOJA <='58'
		AND SA1.A1_MSBLQL ='2'
		and SA1.D_E_L_E_T_ =' '
		GROUP BY A1_COD,A1_NREDUZ,A1_UCELULA,A1_END,A1_EMAIL,A1_UCMFEC,A1_MSBLQL,A1_UCTIPO,Z20_PROVIN,Z20_MUNICI,Z20_DEPART,A1_UCRMLAT,A1_UCRMLON
		
		
	EndSql

	DbSelectArea(OrdenConsul) // seleccionar area Area

	While !(OrdenConsul)->(Eof())

objClientes := JsonObject():new()
		objClientes['CODIGO_CLIENTE']	:= (OrdenConsul)->CODIGO_CLIENTE
		objClientes['NOM_FANT']	:= ALLTRIM((OrdenConsul)->NOM_FANT)
		objClientes['EMAIL']	:= ALLTRIM((OrdenConsul)->EMAIL)
		objClientes['CELULAR']	:= ALLTRIM((OrdenConsul)->CELULAR)
		objClientes['DIRECCION']	:= ALLTRIM((OrdenConsul)->DIRECCION)
		objClientes['F_MODIFICACION']	:= ALLTRIM((OrdenConsul)->F_MODIFICACION)
		objClientes['BASE_CLIENTE']	:= ALLTRIM((OrdenConsul)->BASE_CLIENTE)
		objClientes['ESTADO']	:= ALLTRIM((OrdenConsul)->ESTADO)
		objClientes['PROVINCIA']	:= ALLTRIM((OrdenConsul)->PROVINCIA)
		objClientes['MUNICIPIO']	:= ALLTRIM((OrdenConsul)->MUNICIPIO)
		objClientes['DEPARTAMENTO']	:= ALLTRIM((OrdenConsul)->DEPARTAMENTO)
		objClientes['LATITUD']	:= ALLTRIM((OrdenConsul)->LATITUD)
		objClientes['LONGITUD']	:= ALLTRIM((OrdenConsul)->LONGITUD)
		aadd(aClientes,objClientes)
		(OrdenConsul)->(dbSkip())
	END

	cJson := FWJsonSerialize(aClientes,.T.,.T.)

	cJson := EncodeUtf8(cJson)
	cJson := DecodeUTF8(cJson)

	::SetResponse(cJson)

Return .T.
