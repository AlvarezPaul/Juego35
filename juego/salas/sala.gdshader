shader_type sky;

uniform vec3 color_arriba : source_color = vec3(0.004, 0.006, 0.016);
uniform vec3 color_horizonte : source_color = vec3(0.02, 0.03, 0.07);
uniform float densidad = 45.0;
uniform float brillo_estrellas = 1.6;

float hash(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

void sky() {
	vec3 dir = normalize(EYEDIR);

	// Degradé: un poco más claro hacia el horizonte
	float altura = clamp(dir.y, 0.0, 1.0);
	vec3 base = mix(color_horizonte, color_arriba, pow(altura, 0.5));

	// Estrellas: una por celda, solo en algunas celdas
	vec3 p = dir * densidad;
	vec3 celda = floor(p);
	float r = hash(celda);
	float hay_estrella = step(0.96, r);
	float tam = mix(0.06, 0.22, hash(celda + 7.0));
	float d = length(fract(p) - 0.5);

	// smoothstep da borde suave: se ven difuminadas
	float estrella = smoothstep(tam, 0.0, d) * hay_estrella;

	// Parpadeo leve
	float parpadeo = 0.75 + 0.25 * sin(TIME * (1.0 + r * 3.0) + r * 50.0);

	// No mostrar estrellas por debajo del horizonte
	estrella *= smoothstep(-0.02, 0.15, dir.y);

	COLOR = base + vec3(0.8, 0.85, 1.0) * estrella * brillo_estrellas * parpadeo;
}