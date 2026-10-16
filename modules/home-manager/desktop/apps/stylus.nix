{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        home = {
          packages = with pkgs; [
            xournalpp
            rnote
            krita
          ];
        };

        dconf.settings."com/github/flxzt/rnote" = {
          color-scheme = "force-dark";
          active-fill-color = lib.hm.gvariant.mkTuple [
            (lib.hm.gvariant.mkDouble 0.0)
            (lib.hm.gvariant.mkDouble 0.0)
            (lib.hm.gvariant.mkDouble 0.0)
            (lib.hm.gvariant.mkDouble 0.0)
          ];
          active-stroke-color = lib.hm.gvariant.mkTuple [
            (lib.hm.gvariant.mkDouble 1.0)
            (lib.hm.gvariant.mkDouble 1.0)
            (lib.hm.gvariant.mkDouble 1.0)
            (lib.hm.gvariant.mkDouble 1.0)
          ];
          document-config-preset = ''{"format":{"width":793.701,"height":1122.52,"dpi":96.0,"orientation":"portrait","border_color":{"r":0.467,"g":0.463,"b":0.482,"a":1.0},"show_borders":true,"show_origin_indicator":true},"background":{"color":{"r":0.0,"g":0.0,"b":0.0,"a":1.0},"pattern":"dots","pattern_size":[22.677,22.677],"pattern_color":{"r":0.369,"g":0.361,"b":0.392,"a":1.0}},"layout":"infinite"}'';
          engine-config = ''{"pens_config":{"brush_config":{"builder_type":"modeled","style":"solid","marker_options":{"stroke_width":12.0,"stroke_color":{"r":1.0,"g":1.0,"b":1.0,"a":1.0},"fill_color":{"r":0.0,"g":0.0,"b":0.0,"a":0.0},"pressure_curve":"const","line_style":"solid","line_cap":"straight"},"solid_options":{"stroke_width":3.0,"stroke_color":{"r":1.0,"g":1.0,"b":1.0,"a":1.0},"fill_color":{"r":0.0,"g":0.0,"b":0.0,"a":0.0},"pressure_curve":"linear","line_style":"solid","line_cap":"straight"},"textured_options":{"seed":9841535457133763987,"stroke_width":6.0,"stroke_color":{"r":1.0,"g":1.0,"b":1.0,"a":1.0},"density":5.0,"distribution":"Normal","pressure_curve":"linear"}},"shaper_config":{"builder_type":"line","style":"smooth","smooth_options":{"stroke_width":3.0,"stroke_color":{"r":1.0,"g":1.0,"b":1.0,"a":1.0},"fill_color":{"r":0.0,"g":0.0,"b":0.0,"a":0.0},"pressure_curve":"linear","line_style":"solid","line_cap":"straight"},"rough_options":{"stroke_color":{"r":1.0,"g":1.0,"b":1.0,"a":1.0},"stroke_width":2.4,"fill_color":{"r":0.0,"g":0.0,"b":0.0,"a":0.0},"fill_style":"hachure","hachure_angle":-0.716,"seed":4497954419350131166},"highlight_mode":false,"highlight_opacity":0.45,"constraints":{"enabled":false,"ratios":["one_to_one","horizontal","vertical"]}},"typewriter_config":{"text_style":{"font_family":"serif","font_size":32.0,"font_weight":500,"font_style":"regular","color":{"r":1.0,"g":1.0,"b":1.0,"a":1.0},"max_width":null,"alignment":"start","ranged_text_attributes":[]},"text_width":600.0},"eraser_config":{"width":12.0,"style":"trash_colliding_strokes"},"selector_config":{"style":"polygon","resize_lock_aspectratio":false},"tools_config":{"style":"verticalspace","verticalspace_tool_config":{"limit_movement_horizontal_borders":false,"limit_movement_vertical_borders":false}},"shortcuts":{"drawing_pad_button_2":{"change_pen_style":{"style":"typewriter","mode":"permanent"}},"keyboard_ctrl_space":{"change_pen_style":{"style":"tools","mode":"toggle"}},"touch_two_finger_long_press":{"change_pen_style":{"style":"eraser","mode":"toggle"}},"drawing_pad_button_0":{"change_pen_style":{"style":"brush","mode":"permanent"}},"stylus_primary_button":{"change_pen_style":{"style":"eraser","mode":"temporary"}},"drawing_pad_button_1":{"change_pen_style":{"style":"shaper","mode":"permanent"}},"drawing_pad_button_3":{"change_pen_style":{"style":"eraser","mode":"permanent"}},"mouse_secondary_button":{"change_pen_style":{"style":"shaper","mode":"temporary"}},"stylus_secondary_button":{"change_pen_style":{"style":"selector","mode":"temporary"}}},"pen_mode_pen_style":"brush","pen_mode_eraser_style":"eraser"},"import_prefs":{"pdf_import_prefs":{"page_width_perc":50.0,"page_spacing":"continuous","pages_type":"vector","bitmap_scalefactor":1.8,"adjust_document":false},"xopp_import_prefs":{"pages_type":96.0}},"export_prefs":{"doc_export_prefs":{"with_background":true,"with_pattern":true,"optimize_printing":false,"export_format":"pdf","page_order":"row_major"},"doc_pages_export_prefs":{"with_background":true,"with_pattern":true,"optimize_printing":false,"export_format":"svg","page_order":"row_major","bitmap_scalefactor":1.8,"jpg_quality":85},"selection_export_prefs":{"with_background":true,"with_pattern":false,"optimize_printing":false,"export_format":"svg","bitmap_scalefactor":1.8,"jpg_quality":85,"margin":12.0}},"pen_sounds":false,"optimize_epd":false,"snap_positions":false}'';
          brush-width-1 = 3.0;
          brush-width-2 = 6.0;
          brush-width-3 = 12.0;
          eraser-width-1 = 4.0;
          eraser-width-2 = 9.0;
          eraser-width-3 = 24.0;
          shaper-width-1 = 3.0;
          shaper-width-2 = 6.0;
          shaper-width-3 = 12.0;
          block-pinch-zoom = true;
          inertial-scrolling = false;
          sidebar-show = false;
        };
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence."/persist" = {
        directories = [
          {
            directory = ".config/xournalpp";
            mode = "0700";
          }
          {
            directory = ".cache/krita";
            mode = "0700";
          }
          {
            directory = ".local/share/krita";
            mode = "0700";
          }
          {
            directory = ".local/share/rnote";
            mode = "0700";
          }
        ];
        files = [
          {
            file = ".config/kritadisplayrc";
            parentDirectory = {
              mode = "0700";
            };
          }
          {
            file = ".config/kritarc";
            parentDirectory = {
              mode = "0700";
            };
          }
        ];
      };
    })
  );
}
