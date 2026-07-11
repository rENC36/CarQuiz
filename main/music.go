components {
  id: "music"
  component: "/scripts/music.script"
}
embedded_components {
  id: "sound"
  type: "sound"
  data: "sound: \"/Assets/sounds/menu_music.ogg\"\n"
  "looping: 1\n"
  "gain: 0.4\n"
  ""
}
embedded_components {
  id: "sound_click"
  type: "sound"
  data: "sound: \"/Assets/sounds/click_sound.ogg\"\n"
  ""
}
embedded_components {
  id: "sound_hover"
  type: "sound"
  data: "sound: \"/Assets/sounds/hover_sound.ogg\"\n"
  ""
}
