
USE AdventureWorks2014;
GO


/* 
	1.	Crie um cursor que apresente na tela de mensagens uma lista com o nome dos departamentos da loja (tabela HumanResources.Department) 
		seguido da quantidade de funcion�rios que est�o locados no departamento (obtido a partir da tabela HumanResources. EmployeeDepartmentHistory). 
		Apenas os departamentos que tenham funcion�rios devem ser apresentados. 
*/


CREATE PROCEDURE LojasDepartamento AS 
	BEGIN
	DECLARE @DepartamentName AS nvarchar(50)
	DECLARE @QtdFuncionarios AS int
	DECLARE @StoreCursor AS CURSOR
	SET @StoreCursor = CURSOR FOR
	SELECT HumanResources.Department.Name,
		COUNT(HumanResources.Employee.BusinessEntityID)
	FROM HumanResources.Department
		INNER JOIN HumanResources.EmployeeDepartmentHistory
		ON Department.DepartmentID = EmployeeDepartmentHistory.DepartmentID
		INNER JOIN HumanResources.Employee
		ON EmployeeDepartmentHistory.BusinessEntityID = Employee.BusinessEntityID
	GROUP BY HumanResources.Department.Name
	OPEN @StoreCursor
	FETCH NEXT FROM @StoreCursor
	INTO @DepartamentName,
		@QtdFuncionarios
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @DepartamentName + ' ' + CAST(@QtdFuncionarios AS varchar(50))
		FETCH NEXT FROM @StoreCursor
		INTO @DepartamentName,
		@QtdFuncionarios
	END
	CLOSE @StoreCursor
	DEALLOCATE @StoreCursor
 END;
 GO

EXECUTE LojasDepartamento;

/* 
	2.	Adicione o campo QtyVendor na tabela Production.Product. Crie um cursor do tipo UPDATE para atualizar o novo campo inserido com a quantidade de vendedores relacionados 
		ao produto existentes na tabela Purchasing.ProductVendor. 
*/

ALTER TABLE Production.Product ADD QtyVendor INT;
GO

CREATE PROCEDURE AtualizarVendedores AS
BEGIN 
	DECLARE @ProductID INT DECLARE
	UpdateCursor CURSOR LOCAL KEYSET FOR SELECT
	ProductId 
	FROM
		Production.Product FOR UPDATE OF Production.Product.QtyVendor OPEN UpdateCursor FETCH NEXT 
	FROM
		UpdateCursor INTO @ProductID
	WHILE 
		@@FETCH_STATUS = 0 BEGIN
				UPDATE Production.Product 
				SET Production.Product.QtyVendor = ( SELECT COUNT ( * ) FROM Purchasing.ProductVendor WHERE Purchasing.ProductVendor.ProductID = @ProductID GROUP BY ( Purchasing.ProductVendor.ProductID ) ) 
			WHERE
				CURRENT OF UpdateCursor FETCH NEXT 
			FROM
				UpdateCursor INTO @ProductID;
	
	END CLOSE UpdateCursor DEALLOCATE UpdateCursor
END; 
GO

EXECUTE AtualizarVendedores;
GO

/* 
	3.	Crie uma fun��o de nome SalesMonthTop5 que recebe como par�metro um numero de m�s e ano e apresente como resultado uma lista totalizada com os 5 produtos 
		mais vendidos (considerando a quantidade de itens vendidos) para o m�s informado. 
		A lista de apresentar as seguintes informa��es sobre os produtos: Identificador, Nome do Produto, M�s, Ano, Quantidade Total Vendida, Pre�o Unit�rio M�dio, Desconto Total Concedido e Valor Total Vendido. 
*/


CREATE FUNCTION SalesMonthTop5 (@mes INT, @ano int) RETURNS @Func TABLE (
		Identificador INT, 
		NomeProduto VARCHAR, 
		Mes INT, 
		Ano INT, 
		QuantidadeTotal INT, 
		ValorMedio FLOAT, 
		ValorTotal FLOAT
	) AS 
BEGIN 
	INSERT INTO @Func SELECT TOP 5
		p.ProductID AS [Identificador],
		p.Name AS [Nome do Produto], 
		@mes AS M�s,
	    @ano AS Ano,
		COUNT ( Sales.SalesOrderDetail.ProductID ) AS QtdProdutosVendidos,
		AVG ( Sales.SalesOrderDetail.UnitPrice ) AS ValorM�dio,
		SUM ( Sales.SalesOrderDetail.UnitPrice ) AS ValorTotal
	FROM Production.Product AS p 
		INNER JOIN Sales.SalesOrderDetail ON p.ProductID = Sales.SalesOrderDetail.SalesOrderDetailID
		INNER JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
	WHERE
		YEAR ( Sales.SalesOrderHeader.OrderDate ) = @ano AND MONTH ( Sales.SalesOrderHeader.OrderDate ) = @mes 
	GROUP BY p.ProductID, p.Name
	ORDER BY QtdProdutosVendidos ASC;
	RETURN;
END;
GO

SELECT * FROM SalesMonthTop5(5, 2011);
GO



/* 
	4.	Crie uma fun��o de nome SalesTop5 que recebe como par�metro uma data inicial e uma data final de um per�odo e apresente como resultado uma lista 
	totalizada com os 5 produtos mais vendidos (considerando a quantidade de itens vendidos) para cada m�s do per�odo. 
	A lista de apresentar as seguintes informa��es sobre os produtos: Identificador, Nome do Produto, M�s, Ano, Posi��o (1 a 5), Quantidade Total Vendida, Pre�o Unit�rio M�dio, Desconto Total Concedido e Valor Total Vendido. 
	O campo posi��o representa a ordena��o do ranking do produto dentro de cada m�s.
*/








