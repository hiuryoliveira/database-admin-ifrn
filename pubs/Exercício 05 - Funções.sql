USE Pubs;



/*
	1.	Crie uma função de nome cppublishers que recebe como parâmetro o código de uma editora e retorna uma tabela com as mesmas colunas da tabela publishers, substituindo os primeiros dois dígitos do código da editora por ‘99’ e acrescentando no início do nome da editora o prefixo ‘Copia de’.
*/



CREATE FUNCTION cppublishers(
	@pub_id CHAR(4)
)
RETURNS TABLE AS 
	RETURN (
		SELECT 
			'99' + SUBSTRING(publishers.pub_id, 3, 2) AS pub_id, 
			'Cópia de ' + publishers.pub_name AS pub_name
		FROM 
			publishers
		WHERE publishers.pub_id = @pub_id
	)
GO


SELECT * FROM cppublishers('1389');

/*
	2.	Crie uma função de nome cptitles que recebe como parâmetro o código de uma editora e retorna uma tabela com as mesmas colunas da tabela titles, substituindo os primeiros dois dígitos do código do título por ‘cp’, acrescentando no início do nome do livro o prefixo ‘Copia de’ e substituindo os primeiros dois dígitos do código da editora por ‘99’.
*/


/*
	3.	Crie uma função de nome cptitleauthors que recebe como parâmetro o código de uma editora e retorna uma tabela com as mesmas colunas da tabela titleauthor, substituindo os primeiros dois dígitos do código do título por ‘cp’.
*/


/*
	4.	Crie um procedimento armazenado que recebe como parâmetro o código de uma editora e que, utilizando as funções criadas nas questões anteriores, insira no banco de dados a nova editora, os novos livros e faça a associação dos novos livros com os autores já cadastrados.
*/



/*
	5.	Crie um procedimento armazenado com a mesma finalidade descrita na questão 4, utilizando cursores e sem utilizar as funções criadas na solução das questões anteriores.
*/

