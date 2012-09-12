// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.noConflict();

function setTableFilter(tableName, columnSize){
    var cols = {
        col_0: "none",
        col_3: "select"
    };
    for (var i = columnSize - 1; i > 3; i--) {
        cols["col_" + i] = "none";
    };
    
    
    var props = {
        sort: true,
        filters_row_index: 1,
        rows_counter: true,
        rows_counter_text: "Displayed rows: ",
        btn_reset: true,
        btn_reset_text: "Clear",
        loader: true,
        loader_html: "<img src='/images/img_loading.gif' alt=''='' +='' 'style='vertical-align:middle; margin:0 5px 0 5px'>" +
        "<span>Loading...</span>",
        loader_css_class: 'myLoader',
        base_path: '/javascripts/tableFilter/',
        status_bar: true,
        mark_active_columns: true,
        display_all_text: "< Show all >",
//        enable_default_theme: true,
        rows_always_visible: [1],
        col_width: ['50px', '100px', '100px', '100px'],
        extensions: {
            name: ['ColsVisibility', 'ColumnsResizer'],
            src: ['/javascripts/tableFilter/TFExt_ColsVisibility/TFExt_ColsVisibility.js', '/javascripts/tableFilter/TFExt_ColsResizer/TFExt_ColsResizer.js'],
            description: ['Columns visibility manager', 'Columns Resizing'],
            initialize: [function(o){
                o.SetColsVisibility();
            }
]
        },
        help_instructions_text: "Use the filters above each column to filter and limit table data. Type your text and press Enter.\n Each column can be sorted too"
    };
    for (key in cols) {
        props[key] = cols[key];
    }
    var tf = setFilterGrid(tableName, props);
}
