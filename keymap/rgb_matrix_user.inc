// Per-key reactive white fade + rolling rainbow underglow.
RGB_MATRIX_EFFECT(reactive_underglow)

#ifdef RGB_MATRIX_CUSTOM_EFFECT_IMPLS

// Keypress timestamps, written by process_record_user in keymap.c
extern uint32_t g_key_hit_ts[];

#define KEY_FADE_MS 500
#define UNDERGLOW_FIRST 87
#define UNDERGLOW_COUNT 32

static bool reactive_underglow(effect_params_t* params) {
    RGB_MATRIX_USE_LIMITS(led_min, led_max);

    uint8_t val   = rgb_matrix_get_val();
    uint8_t speed = rgb_matrix_get_speed();

    // Time component for the underglow roll — speed-adjustable
    uint16_t time = scale16by8(g_rgb_timer, qadd8(speed / 4, 1));

    for (uint8_t i = led_min; i < led_max; i++) {
        if (i >= UNDERGLOW_FIRST) {
            // --- Underglow: rolling white wave ---
            uint8_t pos = (i - UNDERGLOW_FIRST) * 255 / UNDERGLOW_COUNT;
            uint8_t wave = sin8(pos + (time & 0xFF));
            uint8_t b = scale8(wave, val);
            rgb_matrix_set_color(i, b, b, b);
        } else {
            // --- Per-key: reactive white fade ---
            uint32_t elapsed = timer_elapsed32(g_key_hit_ts[i]);
            if (elapsed < KEY_FADE_MS) {
                uint8_t b = val - (uint8_t)((uint32_t)val * elapsed / KEY_FADE_MS);
                rgb_matrix_set_color(i, b, b, b);
            } else {
                rgb_matrix_set_color(i, 0, 0, 0);
            }
        }
    }

    return rgb_matrix_check_finished_leds(led_max);
}

#endif
