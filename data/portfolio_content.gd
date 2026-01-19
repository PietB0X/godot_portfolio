## Portfolio Content Data
## Edit this file to add/modify portfolio content
## Format: content_id = { type, title, content, ... }
## 
## HOW TO ADD NEW CONTENT:
## 1. Add new entry in the dictionary below
## 2. Use format: "content_id": { "type": "skill|project|about", ... }
## 3. Content will automatically appear in the game

static func get_all_content() -> Dictionary:
	return {
		# ============================================
		# SKILLS - ? Blöcke
		# ============================================
		"skill_frontend": {
			"type": "skill",
			"title": "Frontend Development",
			"icon": "⚛️",
			"content": "React, React Native, TypeScript, TailwindCSS, HTML/CSS, Vite"
		},
		"skill_backend": {
			"type": "skill",
			"title": "Backend Development",
			"icon": "🔧",
			"content": "Node.js, Express, MongoDB, Socket.io, REST APIs"
		},
		"skill_mobile": {
			"type": "skill",
			"title": "Mobile Development",
			"icon": "📱",
			"content": "React Native, Expo, iOS & Android Development"
		},
		"skill_tools": {
			"type": "skill",
			"title": "Tools & Technologies",
			"icon": "🛠️",
			"content": "Git, Docker, Redux, Zustand, Phaser 3, Godot"
		},
		
		# ============================================
		# PROJECTS - 3D Boards
		# ============================================
		"project_lessingyard": {
			"type": "project",
			"title": "LessingYard",
			"subtitle": "Gamified Learning App",
			"description": "A complete mobile app with gamified learning elements, multiplayer games, and teacher portal. Developed for Lessing-Stadtteilschule Hamburg.",
			"tech_stack": ["React Native", "TypeScript", "Node.js", "MongoDB", "Socket.io"],
			"github_link": "https://gitlab.com/lessingyard",
			"live_link": "",
			"screenshot": "",  # Path to screenshot: "res://screenshots/lessingyard.png"
			"icon": "📱",  # Emoji icon or empty string
			"icon_path": "res://icons/mascot.png"  
		},
		"project_portfolio": {
			"type": "project",
			"title": "Mario Portfolio",
			"subtitle": "This Portfolio!",
			"description": "An interactive, playable portfolio built with Phaser 3 and React. Shows my skills through an RPG-like experience.",
			"tech_stack": ["React", "TypeScript", "Phaser 3", "TailwindCSS"],
			"github_link": "",
			"live_link": "",
			"screenshot": "",
			"icon": "🎮",  # Emoji icon or empty string
			"icon_path": ""  # Path to icon texture: "res://icons/portfolio.png"
		},
		
		# ============================================
		# ABOUT ME - NPCs
		# ============================================
		"about_bio": {
			"type": "about",
			"title": "Über Mich",
			"content": "Nutzerzentrierter Full-Stack Entwickler mit Leidenschaft für gamifizierte Anwendungen und interaktive Experiences."
		},
		"about_location": {
			"type": "about",
			"title": "Standort",
			"content": "📍 Hamburg, Deutschland"
		},
		"about_passion": {
			"type": "about",
			"title": "Leidenschaft",
			"content": "Game Development, Interactive Design, Bildungs-Apps und alles was Spaß macht!"
		}
	}
