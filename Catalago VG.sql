create user pruebapro identified BY 12345;
grant connect to pruebapro;
grant resource to pruebapro;
GRANT CREATE VIEW TO pruebapro;

conn pruebapro
12345


SET SERVEROUTPUT ON;


CREATE TABLE Empresa (
  EMP_id_empresa INT PRIMARY KEY,
  EMP_nombre VARCHAR(50) NOT NULL,
  EMP_sitio_web VARCHAR2(50) NOT NULL,
  EMP_pais VARCHAR2(50) NOT NULL,
  EMP_cantidad_juegos NUMBER DEFAULT 0
);

CREATE TABLE Categoria(
  CAT_id_categoria INT PRIMARY KEY,
  CAT_descripcion VARCHAR2(50) NOT NULL
);

CREATE TABLE TipoConsola(
  TC_id_tipo_consola INT PRIMARY KEY,
  TC_descripcion VARCHAR2(50) NOT NULL
);

CREATE TABLE Consola (
  CON_id_consola INT PRIMARY KEY,
  CON_nombre VARCHAR2(50) NOT NULL,
  CON_fabricante VARCHAR2(50) NOT NULL,
  CON_id_tipo_consola NUMBER NOT NULL,
  CON_cantidad_juegos NUMBER DEFAULT 0,
  CON_lanzamiento DATE,
  CONSTRAINT fk_CON_id_tipo_consola FOREIGN KEY (CON_id_tipo_consola) REFERENCES TipoConsola(TC_id_tipo_consola)
);

CREATE TABLE Juego (
  JUE_id_juego INT PRIMARY KEY,
  JUE_nombre VARCHAR(50) NOT NULL,
  JUE_descripcion VARCHAR2(50) NOT NULL,
  JUE_precio DECIMAL(10, 2) NOT NULL,
  JUE_id_categoria NUMBER NOT NULL,
  JUE_id_empresa NUMBER NOT NULL,
  CONSTRAINT fk_JUE_id_categoria FOREIGN KEY (JUE_id_categoria) REFERENCES Categoria(CAT_id_categoria),
  CONSTRAINT fk_JUE_id_empresa FOREIGN KEY (JUE_id_empresa) REFERENCES Empresa(EMP_id_empresa)
);



CREATE TABLE Empresa_Juego (
  EJ_id_empresa NUMBER,
  EJ_id_juego NUMBER,
  FOREIGN KEY (EJ_id_empresa) REFERENCES Empresa (EMP_id_empresa),
  FOREIGN KEY (EJ_id_juego) REFERENCES Juego (JUE_id_juego)
);


CREATE TABLE Consola_Juego (
  CJ_id_juegoconsola NUMBER PRIMARY KEY,
  CJ_id_consola NUMBER,
  CJ_id_juego NUMBER,
  CONSTRAINT fk_CJ_id_juego FOREIGN KEY (CJ_id_juego) REFERENCES Juego(JUE_id_juego),
  CONSTRAINT fk_CJ_id_consola FOREIGN KEY (CJ_id_consola) REFERENCES Consola(CON_id_consola)
);


CREATE TABLE Auditoria (
  AUD_id_auditoria NUMBER PRIMARY KEY,
  AUD_tabla_afectada VARCHAR2(50) NOT NULL,
  AUD_id_juego NUMBER,
  AUD_operacion varchar2(20) NOT NULL,
  AUD_fechahora DATE NOT NULL,
  AUD_usuario VARCHAR2(50),
  CONSTRAINT fk_AUD_id_juego FOREIGN KEY(AUD_id_juego) REFERENCES Juego(JUE_id_juego)
);

CREATE SEQUENCE sec_id_empresa
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE sec_id_juego
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE sec_id_consola
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE sec_id_auditoria
START WITH 1
INCREMENT BY 1;

create SEQUENCE sec_id_consola_juego
start WITH 1
increment by 1;


CREATE OR REPLACE TRIGGER tr_IntroEmpresa 
AFTER INSERT OR UPDATE OR DELETE ON Juego 
FOR EACH ROW 
BEGIN 
    IF INSERTING THEN
        UPDATE Empresa
        SET EMP_cantidad_juegos = EMP_cantidad_juegos + 1
        WHERE EMP_id_empresa = :NEW.JUE_id_empresa;

    ELSIF UPDATING THEN
        UPDATE Empresa
        SET EMP_cantidad_juegos = EMP_cantidad_juegos + 1
        WHERE EMP_id_empresa = :NEW.JUE_id_empresa;

        UPDATE Empresa
        SET EMP_cantidad_juegos = EMP_cantidad_juegos - 1
        WHERE EMP_id_empresa = :OLD.JUE_id_empresa;

    ELSIF DELETING THEN
        UPDATE Empresa
        SET EMP_cantidad_juegos = EMP_cantidad_juegos - 1
        WHERE EMP_id_empresa = :OLD.JUE_id_empresa;
    END IF; 
END tr_IntroEmpresa;
/

CREATE OR REPLACE TRIGGER tr_Introconsola 
AFTER INSERT OR UPDATE OR DELETE ON Consola_Juego 
FOR EACH ROW 
BEGIN 
    IF INSERTING THEN
        UPDATE Consola
        SET CON_cantidad_juegos = CON_cantidad_juegos + 1
        WHERE CON_id_consola = :NEW.CJ_id_consola;

    ELSIF UPDATING THEN
        UPDATE Consola
        SET CON_cantidad_juegos = CON_cantidad_juegos + 1
        WHERE CON_id_consola = :NEW.CJ_id_consola;

        UPDATE Consola
        SET CON_cantidad_juegos = CON_cantidad_juegos - 1
        WHERE CON_id_consola = :OLD.CJ_id_consola;

    ELSIF DELETING THEN
        UPDATE Consola
        SET CON_cantidad_juegos = CON_cantidad_juegos - 1
        WHERE CON_id_consola = :OLD.CJ_id_consola;
    END IF; 
END tr_Introconsola;
/




CREATE OR REPLACE PROCEDURE inserciontablas AS
BEGIN
  --insercion tabla categorias
  INSERT INTO Categoria(CAT_id_categoria, CAT_descripcion)
  VALUES(1, 'Acción');
  INSERT INTO Categoria(CAT_id_categoria, CAT_descripcion)
  VALUES(2, 'Deporte');
  INSERT INTO Categoria(CAT_id_categoria, CAT_descripcion)
  VALUES(3, 'Aventura');
  INSERT INTO Categoria(CAT_id_categoria, CAT_descripcion)
  VALUES(4, 'Carreras');
  INSERT INTO Categoria(CAT_id_categoria, CAT_descripcion)
  VALUES(5, 'Habilidad');
  --insercion tablas tipo Concola
  INSERT INTO TipoConsola(TC_id_tipo_consola, TC_descripcion)
  VALUES(1, 'Portatil');
  INSERT INTO TipoConsola(TC_id_tipo_consola, TC_descripcion)
  VALUES(2, 'Hibirda');
  INSERT INTO TipoConsola(TC_id_tipo_consola, TC_descripcion)
  VALUES(3, 'Sobremesa');
  INSERT INTO TipoConsola(TC_id_tipo_consola, TC_descripcion)
  VALUES(4, 'Retro');
  INSERT INTO TipoConsola(TC_id_tipo_consola, TC_descripcion)
  VALUES(5, 'Realidad Virtual');
END;
/

BEGIN
inserciontablas;
END;
/

CREATE OR REPLACE PROCEDURE InsertarEmpresa(
    p_nombre in VARCHAR2,
    p_sitioweb in VARCHAR2,
    p_pais in VARCHAR2
)
AS
BEGIN
    INSERT INTO Empresa (EMP_id_empresa, EMP_nombre, EMP_sitio_web, EMP_pais)
    VALUES (sec_id_empresa.NEXTVAL, p_nombre, p_sitioweb, p_pais);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Empresa insertada correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al insertar la empresa: ' || SQLERRM);
END;
/



CREATE OR REPLACE PROCEDURE InsertarConsola(
    p_nombre  IN VARCHAR2,
    p_fabricante IN VARCHAR2,
    p_id_tipo_consola IN NUMBER,
    p_lanzamiento IN DATE
)
AS
BEGIN
    INSERT INTO Consola (CON_id_consola, CON_nombre, CON_fabricante, CON_id_tipo_consola, CON_lanzamiento)
    VALUES (sec_id_consola.NEXTVAL, p_nombre, p_fabricante, p_id_tipo_consola, p_lanzamiento);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Consola insertada correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al insertar la consola: ' || SQLERRM);
END;
/




CREATE OR REPLACE TRIGGER tr_auditoria 
AFTER INSERT OR UPDATE OR DELETE ON Juego 
FOR EACH ROW 
BEGIN 
    IF INSERTING THEN
        INSERT INTO Auditoria (AUD_id_auditoria, AUD_tabla_afectada, AUD_id_juego, AUD_operacion, AUD_fechahora, AUD_usuario) 
        VALUES (sec_id_auditoria.nextval, 'Juego', :NEW.JUE_id_juego, 'I', TO_DATE(SYSDATE, 'DD/MM/YYYY HH24/MI/SS'), USER); 
    ELSIF UPDATING THEN
        INSERT INTO Auditoria (AUD_id_auditoria, AUD_tabla_afectada, AUD_id_juego, AUD_operacion, AUD_fechahora, AUD_usuario) 
        VALUES (sec_id_auditoria.nextval, 'Juego', :NEW.JUE_id_juego, 'A', TO_DATE(SYSDATE, 'DD/MM/YYYY HH24/MI/SS'), USER); 
    ELSIF DELETING THEN
        INSERT INTO Auditoria (AUD_id_auditoria, AUD_tabla_afectada, AUD_id_juego, AUD_operacion, AUD_fechahora, AUD_usuario) 
        VALUES (sec_id_auditoria.nextval, 'Juego', :OLD.JUE_id_juego, 'D', TO_DATE(SYSDATE, 'DD/MM/YYYY HH24/MI/SS'), USER); 
    END IF; 
END tr_auditoria;
/



CREATE OR REPLACE TYPE Consolaid AS TABLE OF NUMBER;
/

CREATE OR REPLACE PROCEDURE LlenarTablaJuego(
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2,
    p_precio IN DECIMAL,
    p_id_categoria IN NUMBER,
    p_id_empresa IN NUMBER,
    p_ids_consolas IN Consolaid
)
AS
BEGIN
    -- Insertar el juego en la tabla Juego
    INSERT INTO Juego(JUE_id_juego, JUE_nombre, JUE_descripcion, JUE_precio, JUE_id_categoria, JUE_id_empresa)
    VALUES (sec_id_juego.NEXTVAL, p_nombre, p_descripcion, p_precio, p_id_categoria, p_id_empresa);

    -- Obtener el ID del juego insertado
    DECLARE
        v_id_juego NUMBER;
    BEGIN
        SELECT MAX(JUE_id_juego) INTO v_id_juego FROM Juego;

        -- Insertar las relaciones entre el juego y las consolas especificadas
        FOR i IN 1..p_ids_consolas.COUNT LOOP
            INSERT INTO Consola_Juego(CJ_id_juegoconsola, CJ_id_consola, CJ_id_juego)
            VALUES (sec_id_consola_juego.NEXTVAL, p_ids_consolas(i), v_id_juego);
        END LOOP;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('El juego ha sido insertado correctamente.');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error al insertar el juego: ' || SQLERRM);
    END;
END;
/



CREATE OR REPLACE FUNCTION ObtenerJuegosMasBaratos
  RETURN SYS_REFCURSOR
IS
  juegos_cursor SYS_REFCURSOR;
BEGIN
  OPEN juegos_cursor FOR
    SELECT JUE_nombre, JUE_precio
    FROM (
      SELECT JUE_nombre, JUE_precio
      FROM Juego
      ORDER BY JUE_precio ASC
    )
    WHERE ROWNUM <= 5;

  RETURN juegos_cursor;
END;
/

CREATE OR REPLACE PROCEDURE VerJuegosMasBaratos AS
  juegos_cursor SYS_REFCURSOR;
  juego_nombre Juego.JUE_nombre%TYPE;
  juego_precio Juego.JUE_precio%TYPE;
BEGIN
  juegos_cursor := ObtenerJuegosMasBaratos(); -- Llamada a la función ObtenerJuegosMasBaratos
  
  LOOP
    FETCH juegos_cursor INTO juego_nombre, juego_precio;
    EXIT WHEN juegos_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || juego_nombre || ', Precio: ' || juego_precio);
  END LOOP;
  
  CLOSE juegos_cursor;
END;
/




CREATE OR REPLACE VIEW VistaJuegosEmpresasConsolas AS
SELECT 
EMP.EMP_nombre AS "Empresa", 
CON.CON_nombre AS "Consola", 
JUE.JUE_nombre AS "Juego", 
('$' || JUE.JUE_precio) as "Precio"
FROM Empresa EMP
JOIN Juego JUE ON EMP.EMP_id_empresa = JUE.JUE_id_empresa
JOIN Consola_Juego CJ ON JUE.JUE_id_juego = CJ.CJ_id_juego
JOIN Consola CON ON CJ.CJ_id_consola = CON.CON_id_consola;






BEGIN 
InsertarEmpresa('Ubisoft', 'https://www.ubisoft.com/', 'Fracia');
InsertarEmpresa('Rockstar Games', 'https://www.rockstargames.com/', 'Estados Unidos');
InsertarEmpresa('Square Enix', 'https://www.square-enix.com/', 'Japón');
InsertarEmpresa('Valve Corporation', 'https://www.valvesoftware.com/', 'Estados Unidos');
InsertarEmpresa('CD Projekt', 'https://www.cdprojekt.com/', 'Polonia');
InsertarEmpresa('Electronic Arts', 'https://www.ea.com/', 'Estados Unidos');
InsertarEmpresa('Activision Blizzard', 'https://www.activisionblizzard.com/', 'Estados Unidos');
InsertarEmpresa('Bethesda Softworks', 'https://bethesda.net/', 'Estados Unidos');



BEGIN
   InsertarConsola('Nintendo Switch', 'Nintendo', 2, TO_DATE('03/03/2017', 'MM/DD/YYYY'));
   InsertarConsola('PlayStation 5', 'Sony Interactive Entertainment', 3, TO_DATE('12/11/2020', 'MM/DD/YYYY'));
   InsertarConsola('Xbox Series X', ' Microsoft', 3, TO_DATE('10/11/2020', 'MM/DD/YYYY'));
   InsertarConsola(' Game Boy', '  Nintendo', 3, TO_DATE('10/11/2020', 'MM/DD/YYYY'));
   InsertarConsola('Oculus Quest 2', '  Facebook Technologies', 5, TO_DATE('12/10/2020', 'MM/DD/YYYY'));
   InsertarConsola('Nintendo 64', 'Nintendo', 3, TO_DATE('09/29/1996', 'MM/DD/YYYY'));
   InsertarConsola('Sega Genesis', 'Sega', 3, TO_DATE('08/14/1989', 'MM/DD/YYYY'));
   InsertarConsola('PlayStation 4', 'Sony Interactive Entertainment', 3, TO_DATE('11/15/2013', 'MM/DD/YYYY'));
   InsertarConsola('Xbox One', 'Microsoft', 3, TO_DATE('11/22/2013', 'MM/DD/YYYY'));
   InsertarConsola('Super Nintendo Entertainment System', 'Nintendo', 3, TO_DATE('11/21/1990', 'MM/DD/YYYY'));
   InsertarConsola('Atari 2600', 'Atari', 4, TO_DATE('09/11/1977', 'MM/DD/YYYY'));
   InsertarConsola('PlayStation 3', 'Sony Interactive Entertainment', 3, TO_DATE('11/17/2006', 'MM/DD/YYYY'));
   InsertarConsola('Xbox 360', 'Microsoft', 3, TO_DATE('11/22/2005', 'MM/DD/YYYY'));
   InsertarConsola('Nintendo GameCube', 'Nintendo', 3, TO_DATE('09/14/2001', 'MM/DD/YYYY'));
   InsertarConsola('Sega Dreamcast', 'Sega', 3, TO_DATE('09/09/1999', 'MM/DD/YYYY'));
   InsertarConsola('Nintendo Entertainment System (NES)', 'Nintendo', 4, TO_DATE('07/15/1983', 'MM/DD/YYYY'));
   InsertarConsola('PlayStation 2', 'Sony Interactive Entertainment', 3, TO_DATE('03/04/2000', 'MM/DD/YYYY'));
   InsertarConsola('Xbox', 'Microsoft', 3, TO_DATE('11/15/2001', 'MM/DD/YYYY'));
   InsertarConsola('Atari 5200', 'Atari', 4, TO_DATE('11/11/1982', 'MM/DD/YYYY'));
   InsertarConsola('Sega Saturn', 'Sega', 3, TO_DATE('11/22/1994', 'MM/DD/YYYY'));
END;
/





BEGIN
  LlenarTablaJuego('Assassins Creed Valhalla', 'Acción y aventura', 59.99, 1, 1, Consolaid(2, 3));
  LlenarTablaJuego('FIFA 22', 'Deporte', 59.99, 2, 6, Consolaid(2, 3));
  LlenarTablaJuego('The Legend of Zelda: Breath of the Wild', 'Aventura', 59.99, 3, 1, Consolaid(1));
  LlenarTablaJuego('Grand Theft Auto V', 'Acción y aventura', 29.99, 4, 2, Consolaid(3, 4));
  LlenarTablaJuego('Mario Kart 8 Deluxe', 'Carreras', 49.99, 5, 6, Consolaid(1, 3));
  LlenarTablaJuego('Resident Evil Village', 'Acción y terror', 59.99, 1, 4, Consolaid(2, 3));
  LlenarTablaJuego('Minecraft', 'Aventura y construcción', 19.99, 3, 5, Consolaid(1, 2, 3, 4));
  LlenarTablaJuego('Call of Duty: Black Ops Cold War', 'Acción y disparos', 59.99, 1, 7, Consolaid(1, 2, 3));
  LlenarTablaJuego('Super Smash Bros. Ultimate', 'Lucha', 4.99, 4, 1, Consolaid(1, 3));
  LlenarTablaJuego('Red Dead Redemption 2', 'Acción y aventura', 39.99, 1, 3, Consolaid(2, 3));
  LlenarTablaJuego('Fortnite', 'Acción y supervivencia', 0.00, 1, 8, Consolaid(1, 2, 3, 4, 5));
  LlenarTablaJuego('The Elder Scrolls V: Skyrim', 'Rol', 39.99, 3, 12, Consolaid(3, 4));
  LlenarTablaJuego('God of War', 'Acción y aventura', 39.99, 1, 2, Consolaid(3));
  LlenarTablaJuego('Super Mario Odyssey', 'Plataformas', 49.99, 4, 1, Consolaid(1));
  LlenarTablaJuego('Halo Infinite', 'Acción y disparos', 59.99, 1, 3, Consolaid(2, 3));
  LlenarTablaJuego('Final Fantasy VII Remake', 'Rol', 59.99, 3, 13, Consolaid(3, 4));
  LlenarTablaJuego('Pokémon Sword', 'RPG', 59.99, 3, 1, Consolaid(1));
  LlenarTablaJuego('Cyberpunk 2077', 'Acción y rol', 59.99, 1, 15, Consolaid(2, 3, 4));
  LlenarTablaJuego('Animal Crossing: New Horizons', 'Simulación', 49.99, 3, 6, Consolaid(1));
  LlenarTablaJuego('Battlefield 2042', 'Acción y disparos', 59.99, 1, 7, Consolaid(2, 3));
  LlenarTablaJuego('The Witcher 3: Wild Hunt', 'Acción y rol', 29.99, 1, 16, Consolaid(2, 3));
  LlenarTablaJuego('Super Mario 3D World + Bowser''s Fury', 'Plataformas', 59.99, 4, 1, Consolaid(1));
  LlenarTablaJuego('Resident Evil 3 Remake', 'Acción y terror', 59.99, 1, 4, Consolaid(2, 3));
  LlenarTablaJuego('Horizon Zero Dawn', 'Acción y aventura', 39.99, 1, 2, Consolaid(3));
  LlenarTablaJuego('Mortal Kombat 11', 'Lucha', 29.99, 4, 1, Consolaid(2, 3));
  LlenarTablaJuego('Ghost of Tsushima', 'Acción y aventura', 59.99, 1, 2, Consolaid(3));
  LlenarTablaJuego('Super Mario Maker 2', 'Plataformas', 59.99, 4, 1, Consolaid(1));
  LlenarTablaJuego('Persona 5 Strikers', 'Rol', 59.99, 3, 13, Consolaid(3, 4));
  LlenarTablaJuego('Devil May Cry 5', 'Acción', 39.99, 1, 2, Consolaid(3, 4));
  LlenarTablaJuego('Resident Evil 7: Biohazard', 'Acción y terror', 29.99, 1, 4, Consolaid(2, 3));
  LlenarTablaJuego('Crash Bandicoot: It''s About Time', 'Plataformas', 59.99, 4, 1, Consolaid(1, 3));
  LlenarTablaJuego('Marvel''s Spider-Man', 'Acción y aventura', 39.99, 1, 2, Consolaid(3));
  LlenarTablaJuego('Doom Eternal', 'Acción y disparos', 59.99, 1, 2, Consolaid(3, 4));
  LlenarTablaJuego('Cuphead', 'Plataformas', 19.99, 4, 1, Consolaid(1));
  LlenarTablaJuego('The Outer Worlds', 'Acción y rol', 39.99, 1, 2, Consolaid(3, 4));
  LlenarTablaJuego('Resident Evil 2 Remake', 'Acción y terror', 59.99, 1, 4, Consolaid(2, 3));
  LlenarTablaJuego('Yakuza: Like a Dragon', 'Rol', 59.99, 3, 13, Consolaid(3, 4));
  LlenarTablaJuego('Star Wars Jedi: Fallen Order', 'Acción y aventura', 59.99, 1, 2, Consolaid(3));
  LlenarTablaJuego('Nioh 2', 'Acción y rol', 49.99, 1, 2, Consolaid(3));
  LlenarTablaJuego('Bloodborne', 'Acción y aventura', 29.99, 1, 2, Consolaid(3));
  LlenarTablaJuego('Sekiro: Shadows Die Twice', 'Acción y aventura', 59.99, 1, 2, Consolaid(3));
END;
/







BEGIN
  VerJuegosMasBaratos;
END;
/




SELECT *
FROM VistaJuegosEmpresasConsolas
;





