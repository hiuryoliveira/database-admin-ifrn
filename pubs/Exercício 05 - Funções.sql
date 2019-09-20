USE Pubs;



/*
	1.	Crie uma fun��o de nome cppublishers que recebe como par�metro o c�digo de uma editora e retorna uma tabela com as mesmas colunas da tabela publishers, substituindo os primeiros dois d�gitos do c�digo da editora por �99� e acrescentando no in�cio do nome da editora o prefixo �Copia de�.
*/



CREATE FUNCTION cppublishers(
	@pub_id CHAR(4)
)
RETURNS TABLE AS 
	RETURN (
		SELECT 
			'99' + SUBSTRING(publishers.pub_id, 3, 2) AS pub_id, 
			'C�pia de ' + publishers.pub_name AS pub_name
		FROM 
			publishers
		WHERE publishers.pub_id = @pub_id
	)
GO


SELECT * FROM cppublishers('1389');

/*
	2.	Crie uma fun��o de nome cptitles que recebe como par�metro o c�digo de uma editora e retorna uma tabela com as mesmas colunas da tabela titles, substituindo os primeiros dois d�gitos do c�digo do t�tulo por �cp�, acrescentando no in�cio do nome do livro o prefixo �Copia de� e substituindo os primeiros dois d�gitos do c�digo da editora por �99�.
*/


/*
	3.	Crie uma fun��o de nome cptitleauthors que recebe como par�metro o c�digo de uma editora e retorna uma tabela com as mesmas colunas da tabela titleauthor, substituindo os primeiros dois d�gitos do c�digo do t�tulo por �cp�.
*/


/*
	4.	Crie um procedimento armazenado que recebe como par�metro o c�digo de uma editora e que, utilizando as fun��es criadas nas quest�es anteriores, insira no banco de dados a nova editora, os novos livros e fa�a a associa��o dos novos livros com os autores j� cadastrados.
*/



/*
	5.	Crie um procedimento armazenado com a mesma finalidade descrita na quest�o 4, utilizando cursores e sem utilizar as fun��es criadas na solu��o das quest�es anteriores.
*/

