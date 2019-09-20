USE Pubs;

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


/* 
	3.	Crie uma view denominada singleauthors com os autores que têm apenas um livro publicado 
	listando o código do autor, o nome do autor, o código do livro, o título do livro e a quantidade de livros. 
	Inclua as opções with schemabinding e with check options nesta view.
*/

CREATE VIEW authoswithonetitle AS 
	SELECT 
		titleauthor.au_id 
	FROM titles AS t 
		INNER JOIN titleauthor ON titleauthor.title_id = t.title_id
	GROUP BY titleauthor.au_id
	HAVING COUNT(titleauthor.au_id) <= 1;
GO

CREATE VIEW singleauthors
	AS 
	SELECT 
		authors.au_id, 
		authors.au_fname, 
		authors.qty, 
		titles.title_id, 
		titles.title
	FROM authors
	INNER JOIN titleauthor ON titleauthor.au_id = authors.au_id
	INNER JOIN titles ON titles.title_id = titleauthor.title_id
	WHERE authors.au_id IN (SELECT * FROM authoswithonetitle) WITH CHECK OPTION;
GO


SELECT * FROM singleauthors ORDER BY au_fname ASC;
GO

/*
	4.	Escreva um comando que altere o campo qty da view singleauthors somando 2 no seu valor para o autor de código '172-32-1176'. 
		Execute o comando e comente o resultado da execução.
*/


ALTER VIEW singleauthors AS 
	SELECT 
		authors.au_id, 
		authors.au_fname, 
		authors.qty + 2, 
		titles.title_id, 
		titles.title
	FROM authors
	INNER JOIN titleauthor ON titleauthor.au_id = authors.au_id
	INNER JOIN titles ON titles.title_id = titleauthor.title_id
	WHERE authors.au_id IN (SELECT * FROM authoswithonetitle) WITH CHECK OPTION;
GO


/*
	5.	Escreva um comando que, utilizando a view singleauthors, altere o nome do livro do autor de código '722-51-5454' incluindo no inicio o texto 'The bible of'. 
		Execute o comando e comente o resultado da execução.
*/


UPDATE singleauthors SET title = 'The bible of' WHERE au_id = '722-51-5454';
GO

/*
	6.	Escreva um comando para excluir a coluna qty da tabela authors. 
	Execute o comando e comente o resultado da execução.
*/

ALTER TABLE authors DROP COLUMN qty;
GO

/*
	7.	Escreva um comando para inserir na view singleauthors os valores au_id = '172-32-1170' au_fname = 'Autor', title_id = 'PS3330' e title = 'Livro teste', qty = 1. 
		Execute o comando e comente o resultado da execução.
*/

INSERT INTO singleauthors (au_id, au_fname, title_id, title, qty) VALUES ('172-32-1170', 'Autor', 'PS3330', 'Livro teste', 1);
GO


/*
8.	Escreva um comando para excluir utilizando a view singleauthors o autor de código '172-32-1176'. 
	Execute o comando e comente o resultado da execução.
*/

DELETE FROM singleauthors WHERE au_id = '172-32-1176';
GO

/*
	9.	Escreva um comando para alterar, utilizando a view singleauthors, o último nome do autor de código '172-32-1176' para 'Black'. 
		Execute o comando e comente o resultado da execução.
*/

UPDATE singleauthors SET au_fname = 'Black' WHERE au_id = '172-32-1176';
GO

/*
	10.	Altere a view singleauthors e inclua a opção de criptografia.
*/

ALTER VIEW singleauthors WITH ENCRYPTION AS 
	SELECT 
		authors.au_id, 
		authors.au_fname, 
		authors.qty, 
		titles.title_id, 
		titles.title
	FROM authors
	INNER JOIN titleauthor ON titleauthor.au_id = authors.au_id
	INNER JOIN titles ON titles.title_id = titleauthor.title_id
	WHERE authors.au_id IN (SELECT * FROM authoswithonetitle) WITH CHECK OPTION;



