Use Pubs;

/*
	1.	Escreva um comando para alterar a tabela authors incluindo os campos qty (quantidade de livros publicados pelo autor) e midprice (preço médio dos livros do autor).
*/

ALTER TABLE authors ADD qty INT, midprice FLOAT;
GO

/*
	2.	Crie um procedimento armazenado para calcular os valores dos campos qty e midprice recém introduzido na tabela de autor de acordo com os dados existentes no banco de dados. 
	Execute este procedimento com objetivo de estabelecer o valor inicial destes campos.
*/


CREATE PROCEDURE ProcCalcMidPrice(
	@CodAuthor CHAR(11)) 
AS
BEGIN
	-- Declarar variáveis.
	DECLARE @QTD_LIVROS INT, @PRECO_MEDIO FLOAT
	
	-- 1. Pegar quantidade de livros que um determinado author têm publicados;
	-- 2. Calcular o valor médio dos livros;
	SELECT 
		@QTD_LIVROS = COUNT(t.title_id), 
		@PRECO_MEDIO = AVG(t.price) 
	FROM titles AS t
		INNER JOIN titleauthor ON titleauthor.title_id = t.title_id
	WHERE titleauthor.au_id = @CodAuthor;

	-- Salvar quantidade de livros e preço médio dos livros.
	UPDATE authors SET 
		authors.qty = @QTD_LIVROS, 
		authors.midprice = @PRECO_MEDIO 
	WHERE 
		authors.au_id = @CodAuthor;
END;
GO

EXECUTE ProcCalcMidPrice '238-95-7766';
GO

EXECUTE ProcCalcMidPrice '213-46-8915';
GO

EXECUTE ProcCalcMidPrice '238-95-7766';
GO

EXECUTE ProcCalcMidPrice '267-41-2394';
GO

EXECUTE ProcCalcMidPrice '274-80-9391';
GO

EXECUTE ProcCalcMidPrice '341-22-1782';
GO

EXECUTE ProcCalcMidPrice '409-56-7008';
GO

EXECUTE ProcCalcMidPrice '427-17-2319';
GO


/*
	3.	Crie gatilhos associados à tabela titleauthor para ajustar os valores dos campos qty e midprice da tabela authors quando houver inclusões ou exclusões nesta tabela. 
*/

CREATE TRIGGER TrigAtualizarCalcMidPrice 
	ON titleauthor FOR INSERT
AS 
BEGIN 
	-- Declarar variáveis.
	DECLARE @CodAuthor CHAR(11);
	SET @CodAuthor = (SELECT au_id FROM INSERTED);

	EXECUTE ProcCalcMidPrice @CodAuthor;

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR('Erro de Processamento – Chame o Adminitrador', 16,1)
		RETURN
	END;
END;
GO


/*
	4.	Crie gatilhos associados à tabela titles para ajustar os valores dos campos qty e midprice da tabela authors quando houver alterações no campo price desta tabela. 
*/

CREATE TRIGGER TrigAtualizarCalcMidPriceTabTitles 
	ON titles 
	FOR UPDATE 
AS 
BEGIN
	-- Declarar variáveis.
	DECLARE @CodAuthor CHAR(11);
	
	SET @CodAuthor = (
		SELECT 
			authors.au_id 
		FROM 
			authors 
		INNER JOIN titleauthor ON titleauthor.au_id = authors.au_id
		INNER JOIN titles ON titles.title_id = titleauthor.title_id
		WHERE titles.title_id = (SELECT title_id FROM INSERTED)
	);

	EXECUTE ProcCalcMidPrice @CodAuthor;

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR('Erro de Processamento – Chame o Adminitrador', 16,1)
		RETURN
	END;

END; 
GO

/*
	5.	Crie comandos para incluir um autor em um livro, para excluir um autor de um livro e para alterar o valor de um livro. 
	Faça um resumo com os comandos utilizados apresentando os valores dos campos qty e midprice da tabela authors antes e após a execução de cada comando.
*/


-- Criando novo autor.
INSERT INTO [dbo].[authors] ([au_id],[au_lname],[au_fname],[phone],[address],[city],[state],[zip],[contract])
     VALUES ('117-29-1996', 'Oliveira', 'Hiury', '998977389', 'Av. Jaguarari, 4980 Casa 20', 'Natal', 'RN', '59064', 1)
GO

UPDATE [dbo].[authors]
   SET [au_lname] = 'Joaquim'
      ,[au_fname] = 'Hiury'
      ,[phone] = '84998977389'
      ,[address] = 'Av. Jaguarari, 4980 Casa 20'
      ,[city] = 'Natal'
      ,[state] = 'RN'
      ,[zip] = '59064'
      ,[contract] = 0
 WHERE [au_id] = '117-29-1996';
GO

-- Adicionando autor em um livro.
INSERT INTO [dbo].[titleauthor]
		   ([au_id],[title_id],[au_ord],[royaltyper])
     VALUES
           ('117-29-1996', 'BU7832', 1, 1)
GO

-- Excluir um autor de um livro.
DELETE FROM [dbo].[titleauthor]
      WHERE au_id = '117-29-1996' AND title_id = 'BU7832';
GO


-- Alterar valor do livro.
UPDATE [dbo].[titles]
   SET [price] = 10.0
 WHERE title_id = 'BU7832'
GO

