--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3
-- Dumped by pg_dump version 15.1

-- Started on 2023-12-28 16:08:35 CST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4362 (class 1262 OID 16898)
-- Name: Prana; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "Prana" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE "Prana" OWNER TO postgres;

\connect "Prana"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 242 (class 1255 OID 17035)
-- Name: sp_add_reserva(integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_add_reserva(p_id_horario integer, p_asiento character varying, p_id_reserva character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$
	declare v_id bigint;
	declare v_error varchar;
	declare my_result json;

	begin
		BEGIN
			INSERT INTO public.pr_reservaciones
			(id, folio, id_horario, id_asiento, fec_registro, usr_registro, fec_baja, usr_baja, nombre_reserva)
			VALUES(nextval('pr_reservaciones_id_seq'::regclass), p_id_reserva, p_id_horario, p_asiento, now(), 'roberto@prana.com', null, null, p_id_reserva)
			    RETURNING id into v_id;

		exception
		when others then 
			v_error := concat('Error: ',sqlerrm);
		END;
	
	SELECT
    json_build_object(
        'id', v_id,
        'error', v_error
    ) into my_result;
	
	return my_result;
	
	end;
$$;


ALTER FUNCTION public.sp_add_reserva(p_id_horario integer, p_asiento character varying, p_id_reserva character varying) OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 17017)
-- Name: sp_get_complejos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_get_complejos() RETURNS json
    LANGUAGE plpgsql
    AS $$
	declare my_result json;
	begin
			
		select 
			(select json_agg(  
				    json_build_object(
				    	'id', (x.id),
				    	'nombre', (x.nombre),
				    	'direccion', (x.direccion)
				    ))
			from (select pc.*
					from pr_complejos pc
					where pc.usr_baja is null
					order by pc.nombre) as x)
			into my_result;
	
		return my_result;
	
	end;
$$;


ALTER FUNCTION public.sp_get_complejos() OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 17019)
-- Name: sp_get_movie_detail(integer, integer, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_get_movie_detail(p_id_movie integer, p_id_complejo integer, p_fec timestamp without time zone) RETURNS json
    LANGUAGE plpgsql
    AS $$
	declare my_result json;
	begin
			
		select 
			(select json_agg(  
				    json_build_object(
				    	'id_pelicula', (x.id),
				    	'nombre', (x.nombre),
				    	'sinopsis', (x.sinopsis),
				    	'url_foto', (x.url_foto),
				    	'duracion', (x.duracion),
				    	'director', (x.director),
				    	'clasificacion', (x.clasificacion),
				    	'actores',(select json_agg(  
											    json_build_object(
											    	'id', (pa.id),
											    	'nombre', (pa.nombre)
											    ))
										from pr_actores pa  
										where pa.id_pelicula = x.id
										and pa.usr_baja is null),
				    	'horarios',(select json_agg(  
											    json_build_object(
											    	'id', (ph.id),
											    	'id_sala', (ph.id_sala),
											    	'ini', (ph.ini),
											    	'fin', (ph.fin),
											    	'costo', (ph.costo),
											    	'sala', (ps.nombre)
											    ))
										from pr_horarios ph  
										inner join pr_salas ps on ps.id = ph.id_sala and ps.id_complejo = p_id_complejo
										where ph.id_pelicula = x.id
										and date(ini) = date(p_fec)
										and ph.usr_baja is null)
				    ))
			from (select pp.*
					from pr_peliculas pp
					where pp.id = p_id_movie) as x)
			into my_result;
	
		return my_result;
	
	end;
$$;


ALTER FUNCTION public.sp_get_movie_detail(p_id_movie integer, p_id_complejo integer, p_fec timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 16996)
-- Name: sp_get_movies(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_get_movies(p_id_complejo integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
	declare my_result json;
	begin
			
		select 
			(select json_agg(  
				    json_build_object(
				    	'id_pelicula', (x.id),
				    	'nombre', (x.nombre),
				    	'sinopsis', (x.sinopsis),
				    	'url_foto', (x.url_foto)
				    ))
			from (select distinct (pp.*)
					from pr_peliculas pp
					inner join pr_horarios ph on ph.id_pelicula = pp.id
					inner join pr_salas ps on ps.id = ph.id_sala and ps.id_complejo = p_id_complejo
					where pp.usr_baja is null
					and pp.fec_ini_vigencia <= now()
					and pp.fec_fin_vigencia >= now()
					order by pp.nombre) as x)
			into my_result;
	
		return my_result;
	
	end;
$$;


ALTER FUNCTION public.sp_get_movies(p_id_complejo integer) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 17018)
-- Name: sp_get_movies(integer, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_get_movies(p_id_complejo integer, p_fec timestamp without time zone) RETURNS json
    LANGUAGE plpgsql
    AS $$
	declare my_result json;
	begin
			
		select 
			(select json_agg(  
				    json_build_object(
				    	'id_pelicula', (x.id),
				    	'nombre', (x.nombre),
				    	'sinopsis', (x.sinopsis),
				    	'url_foto', (x.url_foto)
				    ))
			from (select distinct (pp.*)
					from pr_peliculas pp
					inner join pr_horarios ph on ph.id_pelicula = pp.id
					inner join pr_salas ps on ps.id = ph.id_sala and ps.id_complejo = p_id_complejo
					where pp.usr_baja is null
					and pp.fec_ini_vigencia <= p_fec
					and pp.fec_fin_vigencia >= (p_fec + interval '1 day - 1 sec')
					order by pp.nombre) as x)
			into my_result;
	
		return my_result;
	
	end;
$$;


ALTER FUNCTION public.sp_get_movies(p_id_complejo integer, p_fec timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 17034)
-- Name: sp_get_reservas_horario(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_get_reservas_horario(p_id_horario integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
	declare my_result json;
	begin
			
		select 
			(select json_agg(  
				    json_build_object(
				    	'id', (x.id),
				    	'folio', (x.folio),
				    	'id_asiento', (x.id_asiento),
				    	'nombre_reserva', (x.nombre_reserva)
				    ))
			from (select pp.*
					from pr_reservaciones pp
					where pp.usr_baja is null
					and pp.id_horario = p_id_horario
					order by pp.id_asiento) as x)
			into my_result;
	
		return my_result;
	
	end;
$$;


ALTER FUNCTION public.sp_get_reservas_horario(p_id_horario integer) OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 17021)
-- Name: sp_get_sala(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_get_sala(p_id_sala integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
	declare my_result json;
	begin
			
		select 
			(select json_agg(  
				    json_build_object(
				    	'id', (x.id),
				    	'id_complejo', (x.id_complejo),
				    	'nombre', (x.nombre),
				    	'plano', (to_json(ARRAY[x.plano])->>0),
				    	'num_asientos', (x.num_asientos)
				    ))
			from (select ps.*
					from pr_salas ps
					where ps.id = p_id_sala) as x)
			into my_result;
	
		return my_result;
	
	end;
$$;


ALTER FUNCTION public.sp_get_sala(p_id_sala integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 225 (class 1259 OID 17005)
-- Name: pr_actores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pr_actores (
    id bigint NOT NULL,
    nombre character varying NOT NULL,
    id_pelicula bigint NOT NULL,
    fec_registro timestamp without time zone DEFAULT now() NOT NULL,
    usr_registro character varying NOT NULL,
    fec_baja timestamp without time zone,
    usr_baja character varying
);


ALTER TABLE public.pr_actores OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17004)
-- Name: pr_actores_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pr_actores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pr_actores_id_seq OWNER TO postgres;

--
-- TOC entry 4363 (class 0 OID 0)
-- Dependencies: 224
-- Name: pr_actores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pr_actores_id_seq OWNED BY public.pr_actores.id;


--
-- TOC entry 217 (class 1259 OID 16911)
-- Name: pr_complejos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pr_complejos (
    id bigint NOT NULL,
    nombre character varying NOT NULL,
    direccion character varying,
    fec_registro timestamp without time zone DEFAULT now() NOT NULL,
    usr_registro character varying NOT NULL,
    fec_baja timestamp without time zone,
    usr_baja character varying
);


ALTER TABLE public.pr_complejos OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16910)
-- Name: pr_complejos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pr_complejos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pr_complejos_id_seq OWNER TO postgres;

--
-- TOC entry 4364 (class 0 OID 0)
-- Dependencies: 216
-- Name: pr_complejos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pr_complejos_id_seq OWNED BY public.pr_complejos.id;


--
-- TOC entry 221 (class 1259 OID 16954)
-- Name: pr_horarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pr_horarios (
    id bigint NOT NULL,
    id_pelicula bigint NOT NULL,
    ini timestamp without time zone NOT NULL,
    fin timestamp without time zone NOT NULL,
    fec_registro timestamp without time zone DEFAULT now() NOT NULL,
    usr_registro character varying NOT NULL,
    fec_baja timestamp without time zone,
    usr_baja character varying,
    id_sala bigint NOT NULL,
    costo double precision NOT NULL
);


ALTER TABLE public.pr_horarios OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16953)
-- Name: pr_horarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pr_horarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pr_horarios_id_seq OWNER TO postgres;

--
-- TOC entry 4365 (class 0 OID 0)
-- Dependencies: 220
-- Name: pr_horarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pr_horarios_id_seq OWNED BY public.pr_horarios.id;


--
-- TOC entry 215 (class 1259 OID 16900)
-- Name: pr_peliculas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pr_peliculas (
    id bigint NOT NULL,
    nombre character varying NOT NULL,
    sinopsis character varying NOT NULL,
    fec_registro timestamp without time zone DEFAULT now() NOT NULL,
    usr_registro character varying NOT NULL,
    fec_baja timestamp without time zone,
    usr_baja character varying,
    fec_ini_vigencia timestamp without time zone NOT NULL,
    fec_fin_vigencia timestamp without time zone NOT NULL,
    url_foto character varying NOT NULL,
    duracion integer NOT NULL,
    director character varying NOT NULL,
    clasificacion character varying NOT NULL
);


ALTER TABLE public.pr_peliculas OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16899)
-- Name: pr_peliculas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pr_peliculas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pr_peliculas_id_seq OWNER TO postgres;

--
-- TOC entry 4366 (class 0 OID 0)
-- Dependencies: 214
-- Name: pr_peliculas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pr_peliculas_id_seq OWNED BY public.pr_peliculas.id;


--
-- TOC entry 223 (class 1259 OID 16975)
-- Name: pr_reservaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pr_reservaciones (
    id bigint NOT NULL,
    folio character varying NOT NULL,
    id_horario bigint NOT NULL,
    id_asiento character varying NOT NULL,
    fec_registro timestamp without time zone DEFAULT now() NOT NULL,
    usr_registro character varying NOT NULL,
    fec_baja timestamp without time zone,
    usr_baja character varying,
    nombre_reserva character varying NOT NULL
);


ALTER TABLE public.pr_reservaciones OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16974)
-- Name: pr_reservaciones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pr_reservaciones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pr_reservaciones_id_seq OWNER TO postgres;

--
-- TOC entry 4367 (class 0 OID 0)
-- Dependencies: 222
-- Name: pr_reservaciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pr_reservaciones_id_seq OWNED BY public.pr_reservaciones.id;


--
-- TOC entry 219 (class 1259 OID 16922)
-- Name: pr_salas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pr_salas (
    id bigint NOT NULL,
    id_complejo bigint NOT NULL,
    nombre character varying NOT NULL,
    fec_registro timestamp without time zone DEFAULT now() NOT NULL,
    usr_registro character varying,
    fec_baja timestamp without time zone,
    usr_baja character varying,
    plano json,
    num_asientos integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.pr_salas OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16921)
-- Name: pr_salas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pr_salas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pr_salas_id_seq OWNER TO postgres;

--
-- TOC entry 4368 (class 0 OID 0)
-- Dependencies: 218
-- Name: pr_salas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pr_salas_id_seq OWNED BY public.pr_salas.id;


--
-- TOC entry 4179 (class 2604 OID 17008)
-- Name: pr_actores id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_actores ALTER COLUMN id SET DEFAULT nextval('public.pr_actores_id_seq'::regclass);


--
-- TOC entry 4170 (class 2604 OID 16914)
-- Name: pr_complejos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_complejos ALTER COLUMN id SET DEFAULT nextval('public.pr_complejos_id_seq'::regclass);


--
-- TOC entry 4175 (class 2604 OID 16957)
-- Name: pr_horarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_horarios ALTER COLUMN id SET DEFAULT nextval('public.pr_horarios_id_seq'::regclass);


--
-- TOC entry 4168 (class 2604 OID 16903)
-- Name: pr_peliculas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_peliculas ALTER COLUMN id SET DEFAULT nextval('public.pr_peliculas_id_seq'::regclass);


--
-- TOC entry 4177 (class 2604 OID 16978)
-- Name: pr_reservaciones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_reservaciones ALTER COLUMN id SET DEFAULT nextval('public.pr_reservaciones_id_seq'::regclass);


--
-- TOC entry 4172 (class 2604 OID 16925)
-- Name: pr_salas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_salas ALTER COLUMN id SET DEFAULT nextval('public.pr_salas_id_seq'::regclass);


--
-- TOC entry 4356 (class 0 OID 17005)
-- Dependencies: 225
-- Data for Name: pr_actores; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pr_actores (id, nombre, id_pelicula, fec_registro, usr_registro, fec_baja, usr_baja) VALUES (1, 'Rowan Atkinson', 4, '2023-12-27 21:39:45.2628', 'roberto@prana.com', NULL, NULL);
INSERT INTO public.pr_actores (id, nombre, id_pelicula, fec_registro, usr_registro, fec_baja, usr_baja) VALUES (2, 'Olivia Colman', 4, '2023-12-27 21:39:57.469288', 'roberto@prana.com', NULL, NULL);
INSERT INTO public.pr_actores (id, nombre, id_pelicula, fec_registro, usr_registro, fec_baja, usr_baja) VALUES (3, 'Timothée Chalamet', 4, '2023-12-27 21:40:15.654634', 'roberto@prana.com', NULL, NULL);
INSERT INTO public.pr_actores (id, nombre, id_pelicula, fec_registro, usr_registro, fec_baja, usr_baja) VALUES (4, 'Alfonso Herrera', 3, '2023-12-27 21:40:41.22687', 'roberto@prana.com', NULL, NULL);
INSERT INTO public.pr_actores (id, nombre, id_pelicula, fec_registro, usr_registro, fec_baja, usr_baja) VALUES (5, 'Fernanda Castillo', 3, '2023-12-27 21:40:53.296628', 'roberto@prana.com', NULL, NULL);
INSERT INTO public.pr_actores (id, nombre, id_pelicula, fec_registro, usr_registro, fec_baja, usr_baja) VALUES (6, 'Nicole Kidman', 2, '2023-12-27 21:41:18.213289', 'roberto@prana.com', NULL, NULL);
INSERT INTO public.pr_actores (id, nombre, id_pelicula, fec_registro, usr_registro, fec_baja, usr_baja) VALUES (7, 'Jason Momoa', 2, '2023-12-27 21:41:32.03063', 'roberto@prana.com', NULL, NULL);
INSERT INTO public.pr_actores (id, nombre, id_pelicula, fec_registro, usr_registro, fec_baja, usr_baja) VALUES (8, 'Amber Heard', 2, '2023-12-27 21:41:48.981189', 'roberto@prana.com', NULL, NULL);


--
-- TOC entry 4348 (class 0 OID 16911)
-- Dependencies: 217
-- Data for Name: pr_complejos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pr_complejos (id, nombre, direccion, fec_registro, usr_registro, fec_baja, usr_baja) VALUES (1, 'Cine 1', 'Calle 1', '2023-12-27 21:52:39.130648', 'roberto@prana.com', NULL, NULL);
INSERT INTO public.pr_complejos (id, nombre, direccion, fec_registro, usr_registro, fec_baja, usr_baja) VALUES (2, 'Cine 2', 'Calle 2', '2023-12-27 21:52:47.622059', 'roberto@prana.com', NULL, NULL);


--
-- TOC entry 4352 (class 0 OID 16954)
-- Dependencies: 221
-- Data for Name: pr_horarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pr_horarios (id, id_pelicula, ini, fin, fec_registro, usr_registro, fec_baja, usr_baja, id_sala, costo) VALUES (1, 2, '2023-12-28 11:00:00', '2023-12-28 13:00:00', '2023-12-27 21:56:10.388779', 'roberto@prana.com', NULL, NULL, 1, 70);
INSERT INTO public.pr_horarios (id, id_pelicula, ini, fin, fec_registro, usr_registro, fec_baja, usr_baja, id_sala, costo) VALUES (2, 2, '2023-12-28 11:00:00', '2023-12-28 13:00:00', '2023-12-27 21:56:24.946378', 'roberto@prana.com', NULL, NULL, 4, 80);
INSERT INTO public.pr_horarios (id, id_pelicula, ini, fin, fec_registro, usr_registro, fec_baja, usr_baja, id_sala, costo) VALUES (3, 2, '2023-12-28 16:00:00', '2023-12-28 18:00:00', '2023-12-27 21:56:49.403174', 'roberto@prana.com', NULL, NULL, 1, 70);
INSERT INTO public.pr_horarios (id, id_pelicula, ini, fin, fec_registro, usr_registro, fec_baja, usr_baja, id_sala, costo) VALUES (4, 3, '2023-12-28 11:00:00', '2023-12-28 12:00:00', '2023-12-27 21:57:10.413044', 'roberto@prana.com', NULL, NULL, 2, 70);
INSERT INTO public.pr_horarios (id, id_pelicula, ini, fin, fec_registro, usr_registro, fec_baja, usr_baja, id_sala, costo) VALUES (5, 3, '2023-12-28 14:00:00', '2023-12-28 15:00:00', '2023-12-27 21:57:36.077229', 'roberto@prana.com', NULL, NULL, 2, 70);
INSERT INTO public.pr_horarios (id, id_pelicula, ini, fin, fec_registro, usr_registro, fec_baja, usr_baja, id_sala, costo) VALUES (6, 4, '2023-12-28 11:00:00', '2023-12-28 13:00:00', '2023-12-27 21:58:06.02491', 'roberto@prana.com', NULL, NULL, 3, 80);
INSERT INTO public.pr_horarios (id, id_pelicula, ini, fin, fec_registro, usr_registro, fec_baja, usr_baja, id_sala, costo) VALUES (7, 4, '2023-12-28 18:00:00', '2023-12-28 19:00:00', '2023-12-27 21:58:16.201186', 'roberto@prana.com', NULL, NULL, 3, 80);


--
-- TOC entry 4346 (class 0 OID 16900)
-- Dependencies: 215
-- Data for Name: pr_peliculas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pr_peliculas (id, nombre, sinopsis, fec_registro, usr_registro, fec_baja, usr_baja, fec_ini_vigencia, fec_fin_vigencia, url_foto, duracion, director, clasificacion) VALUES (2, 'Aquaman y El Reino Perdido', 'El director James Wan y el propio Aquaman, Jason Momoa—junto con Patrick Wilson, Amber Heard, Yahya Abdul-Mateen II y Nicole Kidman—regresan en la secuela de la película de DC más taquillera de todos los tiempos: “Aquaman y el Reino Perdido”. Al no poder derrotar a Aquaman la primera vez, Black Manta, todavía impulsado por la necesidad de vengar la muerte de su padre, no se detendrá ante nada para acabar con Aquaman de una vez por todas. Esta vez Black Manta es más formidable que nunca y ejerce el poder del mítico Tridente Negro, que desata una fuerza antigua y malévola. Para derrotarlo, Aquaman recurrirá a su hermano encarcelado Orm, el ex rey de la Atlántida, para forjar una alianza improbable. Juntos, deben dejar de lado sus diferencias para proteger su reino y salvar a la familia de Aquaman y al mundo de una destrucción irreversible.', '2023-12-27 21:30:50.134856', 'roberto@prana.com', NULL, NULL, '2023-12-27 21:30:50.134856', '2024-01-06 21:30:50.134856', 'https://static.cinepolis.com/img/peliculas/44086/1/1/44086.jpg', 124, 'James Wan', 'B');
INSERT INTO public.pr_peliculas (id, nombre, sinopsis, fec_registro, usr_registro, fec_baja, usr_baja, fec_ini_vigencia, fec_fin_vigencia, url_foto, duracion, director, clasificacion) VALUES (3, '¡Patos!', 'La familia Mallard está un poco estancada. Mientras que papá Mack se contenta con mantener a su familia a salvo remando en su estanque de Nueva Inglaterra para siempre, la mamá Pam está ansiosa por cambiar las cosas y mostrarles a sus hijos, el hijo adolescente Dax y la patita Gwen, todo el mundo. Después de que una familia de patos migratorios se posa en su estanque con emocionantes historias de lugares remotos, Pam convence a Mack para que se embarque en un viaje familiar, a través de la ciudad de Nueva York, a la tropical Jamaica. A medida que los patos silvestres se dirigen al sur para pasar el invierno, sus planes bien rápidamente se tuercen. Esta aventura los inspirará a expandir sus horizontes, abrirse a nuevos amigos y lograr más de lo que nunca creyeron posible, mientras les enseña más de lo que nunca imaginaron sobre los demás y sobre sí mismos.', '2023-12-27 21:32:40.503025', 'roberto@prana.com', NULL, NULL, '2023-12-27 21:32:40.503025', '2024-01-06 21:32:40.503025', 'https://static.cinepolis.com/img/peliculas/43449/1/1/43449.jpg', 92, 'Benjamin Renner, Guylo Homsy', 'AA');
INSERT INTO public.pr_peliculas (id, nombre, sinopsis, fec_registro, usr_registro, fec_baja, usr_baja, fec_ini_vigencia, fec_fin_vigencia, url_foto, duracion, director, clasificacion) VALUES (4, 'Wonka', 'Basado en el extraordinario personaje central de Charlie y la fábrica de chocolate, el libro infantil más icónico de Roald Dahl y uno de los libros infantiles más vendidos de todos los tiempos, "Wonka" cuenta la maravillosa historia de cómo el mayor inventor, mago y chocolatero se convirtió en el amado Willy Wonka que conocemos hoy. De Paul King, escritor/director de las películas de "Paddington", David Heyman, productor de "Harry Potter", "Gravity", "Animales Fantásticos" y "Paddington", y los productores Alexandra Derbyshire (las películas de "Paddington", "Jurassic World: Dominion”) y Luke Kelly (“The Witches de Roald Dahl”), llega una embriagadora mezcla de magia y música, caos y emoción, todo contado con un corazón y un humor fabulosos. Protagonizada por Timothée Chalamet en el papel principal, este irresistiblemente vívido e ingenioso espectáculo de pantalla grande presentará al público a un joven Willy Wonka, repleto de ideas y decidido a cambiar el mundo con un delicioso bocado a la vez, demostrando que las mejores cosas de la vida comienza con un sueño, y si tienes la suerte de conocer a Willy Wonka, todo es posible.', '2023-12-27 21:33:42.549712', 'roberto@prana.com', NULL, NULL, '2023-12-27 21:33:42.549712', '2024-01-06 21:33:42.549712', 'https://static.cinepolis.com/img/peliculas/44198/1/1/44198.jpg', 117, 'Paul King', 'A');


--
-- TOC entry 4354 (class 0 OID 16975)
-- Dependencies: 223
-- Data for Name: pr_reservaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pr_reservaciones (id, folio, id_horario, id_asiento, fec_registro, usr_registro, fec_baja, usr_baja, nombre_reserva) VALUES (1, 'cd9c1b5b-087f-485d-9313-23a74307617c', 2, 'A1', '2023-12-28 20:51:28.335635', 'roberto@prana.com', NULL, NULL, 'cd9c1b5b-087f-485d-9313-23a74307617c');
INSERT INTO public.pr_reservaciones (id, folio, id_horario, id_asiento, fec_registro, usr_registro, fec_baja, usr_baja, nombre_reserva) VALUES (2, 'cd9c1b5b-087f-485d-9313-23a74307617c', 2, 'B2', '2023-12-28 20:51:28.554438', 'roberto@prana.com', NULL, NULL, 'cd9c1b5b-087f-485d-9313-23a74307617c');
INSERT INTO public.pr_reservaciones (id, folio, id_horario, id_asiento, fec_registro, usr_registro, fec_baja, usr_baja, nombre_reserva) VALUES (3, '5ea12b6d-ec08-4d0f-8544-e8c412312b7e', 2, 'A4', '2023-12-28 20:52:07.112927', 'roberto@prana.com', NULL, NULL, '5ea12b6d-ec08-4d0f-8544-e8c412312b7e');
INSERT INTO public.pr_reservaciones (id, folio, id_horario, id_asiento, fec_registro, usr_registro, fec_baja, usr_baja, nombre_reserva) VALUES (4, '1555b852-a442-4c59-a115-991ceb9e1aae', 4, 'B1', '2023-12-28 21:52:57.880929', 'roberto@prana.com', NULL, NULL, '1555b852-a442-4c59-a115-991ceb9e1aae');
INSERT INTO public.pr_reservaciones (id, folio, id_horario, id_asiento, fec_registro, usr_registro, fec_baja, usr_baja, nombre_reserva) VALUES (5, '1555b852-a442-4c59-a115-991ceb9e1aae', 4, 'B2', '2023-12-28 21:52:58.042104', 'roberto@prana.com', NULL, NULL, '1555b852-a442-4c59-a115-991ceb9e1aae');
INSERT INTO public.pr_reservaciones (id, folio, id_horario, id_asiento, fec_registro, usr_registro, fec_baja, usr_baja, nombre_reserva) VALUES (6, 'b82794a4-e434-4394-bd3c-7722dd49ac86', 4, 'B3', '2023-12-28 21:53:21.711137', 'roberto@prana.com', NULL, NULL, 'b82794a4-e434-4394-bd3c-7722dd49ac86');
INSERT INTO public.pr_reservaciones (id, folio, id_horario, id_asiento, fec_registro, usr_registro, fec_baja, usr_baja, nombre_reserva) VALUES (7, 'ac8e8652-bf9b-459a-a02d-d2a49bb0360a', 2, 'B3', '2023-12-28 21:59:07.072121', 'roberto@prana.com', NULL, NULL, 'ac8e8652-bf9b-459a-a02d-d2a49bb0360a');


--
-- TOC entry 4350 (class 0 OID 16922)
-- Dependencies: 219
-- Data for Name: pr_salas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pr_salas (id, id_complejo, nombre, fec_registro, usr_registro, fec_baja, usr_baja, plano, num_asientos) VALUES (1, 1, 'Sala 1', '2023-12-27 21:53:29.244041', 'roberto@prana.com', NULL, NULL, '{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 3],
              [3, 3],
              [3, 2],
              [6, 2],
              [6, 3],
              [7, 3],
              [7, 5],
              [6, 5],
              [6, 4],
              [5, 5],
              [4, 5],
              [3, 4],
              [3, 5],
              [2, 5],
              [2, 3]
            ]
          ]
        ]
      },
      "properties": {
        "value": "A1",
        "fill": "gray",
        "name": "A1"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [8, 3],
              [9, 3],
              [9, 2],
              [12, 2],
              [12, 3],
              [13, 3],
              [13, 5],
              [12, 5],
              [12, 4],
              [11, 5],
              [10, 5],
              [9, 4],
              [9, 5],
              [8, 5],
              [8, 3]
            ]
          ]
        ]
      },
      "properties": { "value": "A2", "fill": "gray", "name": "A2" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [16, 3],
              [17, 3],
              [17, 2],
              [20, 2],
              [20, 3],
              [21, 3],
              [21, 5],
              [20, 5],
              [20, 4],
              [19, 5],
              [18, 5],
              [17, 4],
              [17, 5],
              [16, 5],
              [16, 3]
            ]
          ]
        ]
      },
      "properties": { "value": "A3", "fill": "gray", "name": "A3" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [22, 3],
              [23, 3],
              [23, 2],
              [26, 2],
              [26, 3],
              [27, 3],
              [27, 5],
              [26, 5],
              [26, 4],
              [25, 5],
              [24, 5],
              [23, 4],
              [23, 5],
              [22, 5],
              [22, 3]
            ]
          ]
        ]
      },
      "properties": {
        "value":"A4",
        "fill": "gray",
        "name": "A4"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 8],
              [3, 8],
              [3, 7],
              [6, 7],
              [6, 8],
              [7, 8],
              [7, 10],
              [6, 10],
              [6, 9],
              [5, 10],
              [4, 10],
              [3, 9],
              [3, 10],
              [2, 10],
              [2, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B1", "fill": "gray", "name": "B1" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [8, 8],
              [9, 8],
              [9, 7],
              [12, 7],
              [12, 8],
              [13, 8],
              [13, 10],
              [12, 10],
              [12, 9],
              [11, 10],
              [10, 10],
              [9, 9],
              [9, 10],
              [8, 10],
              [8, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B2", "fill": "gray", "name": "B2" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [16, 8],
              [17, 8],
              [17, 7],
              [20, 7],
              [20, 8],
              [21, 8],
              [21, 10],
              [20, 10],
              [20, 9],
              [19, 10],
              [18, 10],
              [17, 9],
              [17, 10],
              [16, 10],
              [16, 8]
            ]
          ]
        ]
      },
      "properties": {
        "value": "B3",
        "fill": "gray",
        "name": "B3"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
             [22, 8],
              [23, 8],
              [23, 7],
              [26, 7],
              [26, 8],
              [27, 8],
              [27, 10],
              [26, 10],
              [26, 9],
              [25, 10],
              [24, 10],
              [23, 9],
              [23, 10],
              [22, 10],
              [22, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B4", "fill": "gray", "name": "B4" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 12],
              [27, 12],
              [27, 13],
              [2, 13],
              [2, 12]
            ]
          ]
        ]
      },
      "properties": { "value": "Pantalla", "fill": "gray", "name": "Pantalla" }
    }
  ]
}
', 8);
INSERT INTO public.pr_salas (id, id_complejo, nombre, fec_registro, usr_registro, fec_baja, usr_baja, plano, num_asientos) VALUES (2, 1, 'Sala 2', '2023-12-27 21:53:34.901057', 'roberto@prana.com', NULL, NULL, '{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 3],
              [3, 3],
              [3, 2],
              [6, 2],
              [6, 3],
              [7, 3],
              [7, 5],
              [6, 5],
              [6, 4],
              [5, 5],
              [4, 5],
              [3, 4],
              [3, 5],
              [2, 5],
              [2, 3]
            ]
          ]
        ]
      },
      "properties": {
        "value": "A1",
        "fill": "gray",
        "name": "A1"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [8, 3],
              [9, 3],
              [9, 2],
              [12, 2],
              [12, 3],
              [13, 3],
              [13, 5],
              [12, 5],
              [12, 4],
              [11, 5],
              [10, 5],
              [9, 4],
              [9, 5],
              [8, 5],
              [8, 3]
            ]
          ]
        ]
      },
      "properties": { "value": "A2", "fill": "gray", "name": "A2" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [16, 3],
              [17, 3],
              [17, 2],
              [20, 2],
              [20, 3],
              [21, 3],
              [21, 5],
              [20, 5],
              [20, 4],
              [19, 5],
              [18, 5],
              [17, 4],
              [17, 5],
              [16, 5],
              [16, 3]
            ]
          ]
        ]
      },
      "properties": { "value": "A3", "fill": "gray", "name": "A3" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [22, 3],
              [23, 3],
              [23, 2],
              [26, 2],
              [26, 3],
              [27, 3],
              [27, 5],
              [26, 5],
              [26, 4],
              [25, 5],
              [24, 5],
              [23, 4],
              [23, 5],
              [22, 5],
              [22, 3]
            ]
          ]
        ]
      },
      "properties": {
        "value":"A4",
        "fill": "gray",
        "name": "A4"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 8],
              [3, 8],
              [3, 7],
              [6, 7],
              [6, 8],
              [7, 8],
              [7, 10],
              [6, 10],
              [6, 9],
              [5, 10],
              [4, 10],
              [3, 9],
              [3, 10],
              [2, 10],
              [2, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B1", "fill": "gray", "name": "B1" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [8, 8],
              [9, 8],
              [9, 7],
              [12, 7],
              [12, 8],
              [13, 8],
              [13, 10],
              [12, 10],
              [12, 9],
              [11, 10],
              [10, 10],
              [9, 9],
              [9, 10],
              [8, 10],
              [8, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B2", "fill": "gray", "name": "B2" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [16, 8],
              [17, 8],
              [17, 7],
              [20, 7],
              [20, 8],
              [21, 8],
              [21, 10],
              [20, 10],
              [20, 9],
              [19, 10],
              [18, 10],
              [17, 9],
              [17, 10],
              [16, 10],
              [16, 8]
            ]
          ]
        ]
      },
      "properties": {
        "value": "B3",
        "fill": "gray",
        "name": "B3"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
             [22, 8],
              [23, 8],
              [23, 7],
              [26, 7],
              [26, 8],
              [27, 8],
              [27, 10],
              [26, 10],
              [26, 9],
              [25, 10],
              [24, 10],
              [23, 9],
              [23, 10],
              [22, 10],
              [22, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B4", "fill": "gray", "name": "B4" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 12],
              [27, 12],
              [27, 13],
              [2, 13],
              [2, 12]
            ]
          ]
        ]
      },
      "properties": { "value": "Pantalla", "fill": "gray", "name": "Pantalla" }
    }
  ]
}
', 8);
INSERT INTO public.pr_salas (id, id_complejo, nombre, fec_registro, usr_registro, fec_baja, usr_baja, plano, num_asientos) VALUES (3, 2, 'Sala 1', '2023-12-27 21:53:43.013287', 'roberto@prana.com', NULL, NULL, '{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 3],
              [3, 3],
              [3, 2],
              [6, 2],
              [6, 3],
              [7, 3],
              [7, 5],
              [6, 5],
              [6, 4],
              [5, 5],
              [4, 5],
              [3, 4],
              [3, 5],
              [2, 5],
              [2, 3]
            ]
          ]
        ]
      },
      "properties": {
        "value": "A1",
        "fill": "gray",
        "name": "A1"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [8, 3],
              [9, 3],
              [9, 2],
              [12, 2],
              [12, 3],
              [13, 3],
              [13, 5],
              [12, 5],
              [12, 4],
              [11, 5],
              [10, 5],
              [9, 4],
              [9, 5],
              [8, 5],
              [8, 3]
            ]
          ]
        ]
      },
      "properties": { "value": "A2", "fill": "gray", "name": "A2" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [16, 3],
              [17, 3],
              [17, 2],
              [20, 2],
              [20, 3],
              [21, 3],
              [21, 5],
              [20, 5],
              [20, 4],
              [19, 5],
              [18, 5],
              [17, 4],
              [17, 5],
              [16, 5],
              [16, 3]
            ]
          ]
        ]
      },
      "properties": { "value": "A3", "fill": "gray", "name": "A3" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [22, 3],
              [23, 3],
              [23, 2],
              [26, 2],
              [26, 3],
              [27, 3],
              [27, 5],
              [26, 5],
              [26, 4],
              [25, 5],
              [24, 5],
              [23, 4],
              [23, 5],
              [22, 5],
              [22, 3]
            ]
          ]
        ]
      },
      "properties": {
        "value":"A4",
        "fill": "gray",
        "name": "A4"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 8],
              [3, 8],
              [3, 7],
              [6, 7],
              [6, 8],
              [7, 8],
              [7, 10],
              [6, 10],
              [6, 9],
              [5, 10],
              [4, 10],
              [3, 9],
              [3, 10],
              [2, 10],
              [2, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B1", "fill": "gray", "name": "B1" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [8, 8],
              [9, 8],
              [9, 7],
              [12, 7],
              [12, 8],
              [13, 8],
              [13, 10],
              [12, 10],
              [12, 9],
              [11, 10],
              [10, 10],
              [9, 9],
              [9, 10],
              [8, 10],
              [8, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B2", "fill": "gray", "name": "B2" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [16, 8],
              [17, 8],
              [17, 7],
              [20, 7],
              [20, 8],
              [21, 8],
              [21, 10],
              [20, 10],
              [20, 9],
              [19, 10],
              [18, 10],
              [17, 9],
              [17, 10],
              [16, 10],
              [16, 8]
            ]
          ]
        ]
      },
      "properties": {
        "value": "B3",
        "fill": "gray",
        "name": "B3"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
             [22, 8],
              [23, 8],
              [23, 7],
              [26, 7],
              [26, 8],
              [27, 8],
              [27, 10],
              [26, 10],
              [26, 9],
              [25, 10],
              [24, 10],
              [23, 9],
              [23, 10],
              [22, 10],
              [22, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B4", "fill": "gray", "name": "B4" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 12],
              [27, 12],
              [27, 13],
              [2, 13],
              [2, 12]
            ]
          ]
        ]
      },
      "properties": { "value": "Pantalla", "fill": "gray", "name": "Pantalla" }
    }
  ]
}
', 8);
INSERT INTO public.pr_salas (id, id_complejo, nombre, fec_registro, usr_registro, fec_baja, usr_baja, plano, num_asientos) VALUES (4, 2, 'Sala 2', '2023-12-27 21:53:55.616511', 'roberto@prana.com', NULL, NULL, '{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 3],
              [3, 3],
              [3, 2],
              [6, 2],
              [6, 3],
              [7, 3],
              [7, 5],
              [6, 5],
              [6, 4],
              [5, 5],
              [4, 5],
              [3, 4],
              [3, 5],
              [2, 5],
              [2, 3]
            ]
          ]
        ]
      },
      "properties": {
        "value": "A1",
        "fill": "gray",
        "name": "A1"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [8, 3],
              [9, 3],
              [9, 2],
              [12, 2],
              [12, 3],
              [13, 3],
              [13, 5],
              [12, 5],
              [12, 4],
              [11, 5],
              [10, 5],
              [9, 4],
              [9, 5],
              [8, 5],
              [8, 3]
            ]
          ]
        ]
      },
      "properties": { "value": "A2", "fill": "gray", "name": "A2" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [16, 3],
              [17, 3],
              [17, 2],
              [20, 2],
              [20, 3],
              [21, 3],
              [21, 5],
              [20, 5],
              [20, 4],
              [19, 5],
              [18, 5],
              [17, 4],
              [17, 5],
              [16, 5],
              [16, 3]
            ]
          ]
        ]
      },
      "properties": { "value": "A3", "fill": "gray", "name": "A3" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [22, 3],
              [23, 3],
              [23, 2],
              [26, 2],
              [26, 3],
              [27, 3],
              [27, 5],
              [26, 5],
              [26, 4],
              [25, 5],
              [24, 5],
              [23, 4],
              [23, 5],
              [22, 5],
              [22, 3]
            ]
          ]
        ]
      },
      "properties": {
        "value":"A4",
        "fill": "gray",
        "name": "A4"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 8],
              [3, 8],
              [3, 7],
              [6, 7],
              [6, 8],
              [7, 8],
              [7, 10],
              [6, 10],
              [6, 9],
              [5, 10],
              [4, 10],
              [3, 9],
              [3, 10],
              [2, 10],
              [2, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B1", "fill": "gray", "name": "B1" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [8, 8],
              [9, 8],
              [9, 7],
              [12, 7],
              [12, 8],
              [13, 8],
              [13, 10],
              [12, 10],
              [12, 9],
              [11, 10],
              [10, 10],
              [9, 9],
              [9, 10],
              [8, 10],
              [8, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B2", "fill": "gray", "name": "B2" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [16, 8],
              [17, 8],
              [17, 7],
              [20, 7],
              [20, 8],
              [21, 8],
              [21, 10],
              [20, 10],
              [20, 9],
              [19, 10],
              [18, 10],
              [17, 9],
              [17, 10],
              [16, 10],
              [16, 8]
            ]
          ]
        ]
      },
      "properties": {
        "value": "B3",
        "fill": "gray",
        "name": "B3"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
             [22, 8],
              [23, 8],
              [23, 7],
              [26, 7],
              [26, 8],
              [27, 8],
              [27, 10],
              [26, 10],
              [26, 9],
              [25, 10],
              [24, 10],
              [23, 9],
              [23, 10],
              [22, 10],
              [22, 8]
            ]
          ]
        ]
      },
      "properties": { "value": "B4", "fill": "gray", "name": "B4" }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [2, 12],
              [27, 12],
              [27, 13],
              [2, 13],
              [2, 12]
            ]
          ]
        ]
      },
      "properties": { "value": "Pantalla", "fill": "gray", "name": "Pantalla" }
    }
  ]
}
', 8);


--
-- TOC entry 4369 (class 0 OID 0)
-- Dependencies: 224
-- Name: pr_actores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pr_actores_id_seq', 9, true);


--
-- TOC entry 4370 (class 0 OID 0)
-- Dependencies: 216
-- Name: pr_complejos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pr_complejos_id_seq', 2, true);


--
-- TOC entry 4371 (class 0 OID 0)
-- Dependencies: 220
-- Name: pr_horarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pr_horarios_id_seq', 7, true);


--
-- TOC entry 4372 (class 0 OID 0)
-- Dependencies: 214
-- Name: pr_peliculas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pr_peliculas_id_seq', 4, true);


--
-- TOC entry 4373 (class 0 OID 0)
-- Dependencies: 222
-- Name: pr_reservaciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pr_reservaciones_id_seq', 7, true);


--
-- TOC entry 4374 (class 0 OID 0)
-- Dependencies: 218
-- Name: pr_salas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pr_salas_id_seq', 4, true);


--
-- TOC entry 4198 (class 2606 OID 17013)
-- Name: pr_actores pr_actores_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_actores
    ADD CONSTRAINT pr_actores_pk PRIMARY KEY (id);


--
-- TOC entry 4186 (class 2606 OID 16919)
-- Name: pr_complejos pr_complejos_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_complejos
    ADD CONSTRAINT pr_complejos_pk PRIMARY KEY (id);


--
-- TOC entry 4192 (class 2606 OID 16962)
-- Name: pr_horarios pr_horarios_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_horarios
    ADD CONSTRAINT pr_horarios_pk PRIMARY KEY (id);


--
-- TOC entry 4183 (class 2606 OID 16908)
-- Name: pr_peliculas pr_peliculas_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_peliculas
    ADD CONSTRAINT pr_peliculas_pk PRIMARY KEY (id);


--
-- TOC entry 4195 (class 2606 OID 16983)
-- Name: pr_reservaciones pr_reservaciones_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_reservaciones
    ADD CONSTRAINT pr_reservaciones_pk PRIMARY KEY (id);


--
-- TOC entry 4189 (class 2606 OID 16930)
-- Name: pr_salas pr_salas_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_salas
    ADD CONSTRAINT pr_salas_pk PRIMARY KEY (id);


--
-- TOC entry 4196 (class 1259 OID 17014)
-- Name: pr_actores_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pr_actores_id_idx ON public.pr_actores USING btree (id);


--
-- TOC entry 4184 (class 1259 OID 16920)
-- Name: pr_complejos_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pr_complejos_id_idx ON public.pr_complejos USING btree (id);


--
-- TOC entry 4190 (class 1259 OID 16973)
-- Name: pr_horarios_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pr_horarios_id_idx ON public.pr_horarios USING btree (id);


--
-- TOC entry 4181 (class 1259 OID 16909)
-- Name: pr_peliculas_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pr_peliculas_id_idx ON public.pr_peliculas USING btree (id);


--
-- TOC entry 4193 (class 1259 OID 16994)
-- Name: pr_reservaciones_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pr_reservaciones_id_idx ON public.pr_reservaciones USING btree (id);


--
-- TOC entry 4187 (class 1259 OID 16936)
-- Name: pr_salas_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pr_salas_id_idx ON public.pr_salas USING btree (id);


--
-- TOC entry 4200 (class 2606 OID 16963)
-- Name: pr_horarios pr_horarios_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_horarios
    ADD CONSTRAINT pr_horarios_fk FOREIGN KEY (id_pelicula) REFERENCES public.pr_peliculas(id);


--
-- TOC entry 4201 (class 2606 OID 16968)
-- Name: pr_horarios pr_horarios_sala_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_horarios
    ADD CONSTRAINT pr_horarios_sala_fk FOREIGN KEY (id_sala) REFERENCES public.pr_salas(id);


--
-- TOC entry 4202 (class 2606 OID 16984)
-- Name: pr_reservaciones pr_reservaciones_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_reservaciones
    ADD CONSTRAINT pr_reservaciones_fk FOREIGN KEY (id_horario) REFERENCES public.pr_horarios(id);


--
-- TOC entry 4199 (class 2606 OID 16931)
-- Name: pr_salas pr_salas_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pr_salas
    ADD CONSTRAINT pr_salas_fk FOREIGN KEY (id_complejo) REFERENCES public.pr_complejos(id);


-- Completed on 2023-12-28 16:08:45 CST

--
-- PostgreSQL database dump complete
--

