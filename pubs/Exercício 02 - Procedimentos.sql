USE Pubs;


/*
	1.	Escreva um comando que exiba o código do livro, o título do livro e o nome do autor, 
	por ordem crescente de titulo do livro e nome de autor.
*/


SELECT 
	t.title_id AS [CodLivro], 
	t.title AS [TituloLivro], 
	authors.au_fname AS [NomeAutor]
FROM titles AS t 
	INNER JOIN titleauthor ON t.title_id = titleauthor.title_id
	INNER JOIN authors ON titleauthor.au_id = authors.au_id
	ORDER BY t.title, authors.au_fname;
GO

/*
	2.	Escreva um comando que exiba o código do livro, o título do livro e a quantidade de autores do livro, ordenando por título do livro.
*/


SELECT 
	t.title_id AS [CodLivro], 
	t.title AS [TituloLivro], 
	COUNT(titleauthor.au_id) AS [QtdAutores]
FROM titles AS t 
	INNER JOIN titleauthor ON t.title_id = titleauthor.title_id
	GROUP BY t.title_id, t.title
	ORDER BY t.title;
GO


/*
	3.	Escreva um comando que liste as editoras com mais de 5 livros editados
*/

SELECT 
	pub.pub_name AS [Editora] 
	FROM publishers AS pub 
	INNER JOIN titles AS t ON t.pub_id = pub.pub_id
	GROUP BY pub.pub_name HAVING COUNT(t.pub_id) > 5;
GO


/*
	4.	Crie um procedimento armazenado para inserir uma nova loja de livros. 
	Apresente os comandos utilizados para executar este procedimento.
*/


CREATE PROCEDURE InserirNovaLoja(
	@stor_id CHAR(4), 
	@stor_name VARCHAR(40), 
	@stor_address VARCHAR(40), 
	@city VARCHAR(20), 
	@state CHAR(2),
	@zip CHAR(5)) 
AS 
BEGIN 
	INSERT INTO stores VALUES (@stor_id, @stor_name, @stor_address, @city, @state, @zip);
END;
GO

EXEC InserirNovaLoja 1170, 'Saraiva', 'Midway', 'Natal', 'RN', '59064';
GO


/*
	5.	Crie um procedimento armazenado para apagar as lojas de livros que não realizaram vendas. 
	Apresente os comandos utilizados para executar este procedimento.
*/


CREATE PROCEDURE ApagarLoja(
	@stor_id CHAR(4)
) AS 
BEGIN 
	DELETE FROM stores WHERE stores.stor_id = @stor_id;
END;
GO

EXEC ApagarLoja 1170;
GO

/*
	6.	Escreva comandos que permitam listar os livros da editora com maior quantidade de títulos editados. 
		Apresentar a listagem incluindo a editora, o título do livro e o nome dos autores.
*/


SELECT 
	pub.pub_name,
	COUNT(t.pub_id) AS QtdLivros
FROM publishers AS pub
	INNER JOIN titles AS t ON t.pub_id = pub.pub_id
	GROUP BY pub.pub_name
	ORDER BY QtdLivros DESC;
GO

