USE AdventureWorks2014;

GO
	;
/* 
	1.	Crie uma função de nome SalesMonth que recebe como parâmetro um numero de mês e um numero de ano e 
		apresenta uma lista totalizada com os produtos vendidos no mês e ano passados como parâmetro. 
		A lista de apresentar as seguintes informações sobre os produtos: 
		Identificador, Mês, Ano, Quantidade Total Vendida, Preço Unitário Médio, Desconto Total Concedido e Valor Total Vendido. 
*/
CREATE FUNCTION SalesMonth ( @mes AS INT, @ano AS INT ) RETURNS TABLE AS RETURN (
	SELECT
		Sales.SalesOrderDetail.ProductID,
		AVG (
		MONTH ( Sales.SalesOrderHeader.OrderDate )) AS Mês,
		AVG (
		YEAR ( Sales.SalesOrderHeader.OrderDate )) AS Ano,
		COUNT ( Sales.SalesOrderDetail.ProductID ) AS QtdProdutos,
		AVG ( Sales.SalesOrderDetail.UnitPrice ) AS Valor,
		SUM ( Sales.SalesOrderDetail.UnitPriceDiscount ) AS Desconto,
		SUM ( Sales.SalesOrderDetail.UnitPrice ) AS ValorTotal 
	FROM
		Sales.SalesOrderDetail
		INNER JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID 
	WHERE
		YEAR ( Sales.SalesOrderHeader.OrderDate ) = @ano 
		AND MONTH ( Sales.SalesOrderHeader.OrderDate ) = @mes 
	GROUP BY
		Sales.SalesOrderDetail.ProductID 
	) 
GO
	;
SELECT
	* 
FROM
	SalesMonth ( 06, 2011 );

GO
	;
/* 
	2.	Crie uma função de nome SalesMonthIncrease que recebe como parâmetro um numero de mês e um numero de ano e 
		apresenta uma lista com os produtos que obtiveram aumento de vendas (considere aqui o aumento em relação ao valor total vendido) 
		do mês solicitado em relação ao mês anterior. 
		A lista de apresentar as seguintes informações sobre os produtos: Identificador, Mês (atual), Ano (atual), Quantidade Total Vendida (mês anterior), 
		Valor Total Vendido (mês anterior), Quantidade Total Vendida (mês informado), Valor Total Vendido (mês informado), 
		percentual de aumento de vendas (em relação ao valor total vendido). 
*/
CREATE FUNCTION SalesMonthIncrease ( @mes AS INT, @ano AS INT ) RETURNS @Func TABLE (
	ProductID INT NOT NULL,
	MesAtual INT NOT NULL,
	AnoAtual INT NOT NULL,
	QtdVendidaAnterior INT NOT NULL,
	ValorTotalAnterior MONEY NOT NULL,
	QtdVendidaAtual INT NOT NULL,
	ValorTotalAtual MONEY NOT NULL,
	PorcentagemAumento FLOAT NOT NULL 
	) AS BEGIN
	DECLARE
		@MesAnterior INT, @AnoAnterior INT 
		SET @MesAnterior = @mes - 1 
		SET @AnoAnterior = @ano
	IF
		@mes = 1 BEGIN
			
			SET @MesAnterior = 12 
			SET @AnoAnterior = @ano - 1 
		END INSERT INTO @Func SELECT
		ATUAL.ProductID,
		ATUAL.Mê s AS MêsAtual,
		ATUAL.Ano AS AnoAtual,
		ANTERIOR.QtdProdutos AS QtdProdutosAnt,
		ANTERIOR.ValorTotal AS ValorTotalAnt,
		ATUAL.QtdProdutos AS QtdProdutosAtual,
		ATUAL.ValorTotal AS ValorTotalAtual,
		( ATUAL.ValorTotal - ANTERIOR.ValorTotal ) / ( ANTERIOR.ValorTotal ) * ( 100 ) AS PorcentagemAumento 
	FROM
		SalesMonth ( @mes, @ano ) ATUAL,
		SalesMonth ( @MesAnterior, @AnoAnterior ) ANTERIOR 
	WHERE
		ATUAL.ProductID = ANTERIOR.ProductID 
		AND ATUAL.ValorTotal > ANTERIOR.ValorTotal 
	ORDER BY
		ProductID RETURN 
	END 
	GO
		;
	SELECT
		* 
	FROM
		SalesMonthIncrease ( 05, 2014 );
	
	GO
		;
/* 
	3.	Crie uma função de nome CategorySalesMonth que recebe como parâmetro um numero de mês e um numero de ano e 
		apresenta uma lista com os totais vendidos por categoria de produto no mês e ano passados como parâmetro. 
		A lista de apresentar as seguintes informações sobre as categorias: Identificador da Categoria (ProductCategoryID), 
		Nome da Categoria (ProductCategory), Mês, Ano, Quantidade de Itens Vendidos, Preço Unitário Médio do Item, Valor Total Vendido.  
*/
	CREATE FUNCTION CategorySalesMonth ( @mes AS INT, @ano AS INT ) RETURNS TABLE AS RETURN (
		SELECT
			Production.ProductCategory.ProductCategoryID,
			Production.ProductCategory.Name,
			@mes AS Mês,
			@ano AS Ano,
			COUNT ( Sales.SalesOrderDetail.ProductID ) AS QtdProdutosVendidos,
			AVG ( Sales.SalesOrderDetail.UnitPrice ) AS ValorMédio,
			SUM ( Sales.SalesOrderDetail.UnitPrice ) AS ValorTotal 
		FROM
			Production.Product
			INNER JOIN Production.ProductSubcategory ON ProductSubcategory.ProductSubcategoryID = Product.ProductSubcategoryID
			INNER JOIN Production.ProductCategory ON ProductCategory.ProductCategoryID = ProductSubcategory.ProductCategoryID
			INNER JOIN Sales.SalesOrderDetail ON SalesOrderDetail.ProductID = Product.ProductID
			INNER JOIN Sales.SalesOrderHeader ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID 
		WHERE
			YEAR ( Sales.SalesOrderHeader.OrderDate ) = @ano 
			AND MONTH ( Sales.SalesOrderHeader.OrderDate ) = @mes 
		GROUP BY
			Production.ProductCategory.Name,
			Production.ProductCategory.ProductCategoryID 
		) 
	GO
		;
	SELECT
		* 
	FROM
		CategorySalesMonth ( 05, 2014 );
	
	GO
		;
/* 
	4.	Crie uma função de nome CategoryTopIncrease que recebe como parâmetro um numero de mês e um numero de ano e 
		apresenta dados de vendas da categoria de produtos que teve maior aumento de venda na comparação do mesm informado com o mesmo mês do ano anterior. 
		A função deve apresentar as seguintes informações sobre a categoria: Identificador da Categoria (ProductCategoryID), Nome da Categoria (ProductCategory), 
		Mês, Ano, Quantidade Total Vendida (ano anterior), Valor Total Vendido (ano anterior), Quantidade Total Vendida (mês informado), 
		Valor Total Vendido (mês informado), percentual de aumento de vendas (em relação ao valor total vendido). 
*/
	CREATE FUNCTION CategoryTopIncrease ( @mes AS INT,
		@ano AS INT ) RETURNS @Func TABLE (
		ProductCategoryID INT NOT NULL,
		NomeCategoria nvarchar ( 50 ) NOT NULL,
		Mês INT NOT NULL,
		Ano INT NOT NULL,
		QtdVendidaAnterior INT NOT NULL,
		ValorTotalAnterior money NOT NULL,
		QtdVendidaAtual INT NOT NULL,
		ValorTotalAtual money NOT NULL,
		PorcentagemAumento FLOAT NOT NULL 
		) AS BEGIN
		DECLARE
			@AnoAnterior INT 
			SET @AnoAnterior = @ano - 1 INSERT INTO @Func SELECT TOP
			1 ATUAL.ProductCategoryID,
			ATUAL.Name,
			@mes AS Mês,
			@ano AS Ano,
			ANTERIOR.QtdProdutosVendidos,
			ANTERIOR.ValorTotal,
			ATUAL.QtdProdutosVendidos,
			ATUAL.ValorTotal,
			( ATUAL.ValorTotal - ANTERIOR.ValorTotal ) / ( ANTERIOR.ValorTotal ) * ( 100 ) 
		FROM
			CategorySalesMonth ( @mes, @ano ) ATUAL,
			CategorySalesMonth ( @mes, @AnoAnterior ) ANTERIOR 
		WHERE
			ATUAL.ProductCategoryID = ANTERIOR.ProductCategoryID 
			AND ATUAL.ValorTotal > ANTERIOR.ValorTotal 
		ORDER BY
			( ATUAL.ValorTotal - ANTERIOR.ValorTotal ) / ( ANTERIOR.ValorTotal ) * ( 100 ) DESC RETURN 
		END 
		GO
			;
		SELECT
			* 
		FROM
			CategoryTopIncrease ( 03, 2014 );
		
	GO
	;