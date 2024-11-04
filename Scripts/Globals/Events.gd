extends Node

signal wave_done
signal in_interaction
signal out_interaction
signal shop_open
signal shop_done
signal end_game


#Visual Feedback signals
signal fx_chromatic_aberration(duration : float, intensity : float)
signal fx_blur(duration : float, intensity : float)
signal fx_fish_eye(duration : float, intensity: float)
signal fx_pixelate(duration : float, intensity: float)
signal fx_glitch(duration : float, instensity: float)
signal fx_crt(duration : float, instensity: float)
signal fx_speed_lines(duration : float)
signal fx_screen_shake(duration : float, intensity : float)
signal fx_screen_shake_toggle(intensity : float)
signal fx_vignette(duration : float)
