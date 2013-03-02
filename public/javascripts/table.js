// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.noConflict();

function setTableFilter(tableName, cols, sort_cols, initial_column, paginate){
    var props = {
        sort: true,
        paging: paginate,
        paging_length: 25,
        remember_page_length: true,
        results_per_page: ['Results per page', [25, 50, 100]],
        filters_row_index: 1,
        rows_counter: true,
        rows_counter_text: "Displayed rows: ",
        btn_reset: true,
        btn_reset_text: "Clear",
        loader: false,
        loader_html: "<img src='/images/img_loading.gif' alt=''='' +='' 'style='vertical-align:middle; margin:0 5px 0 5px'>" +
        "<span>Loading...</span>",
        loader_css_class: 'myLoader',
        base_path: '/javascripts/tableFilter/',
        status_bar: true,
        mark_active_columns: true,
        display_all_text: "< Show all >",
        alternate_rows: true,
        //        enable_default_theme: true,
        rows_always_visible: [1],
        //        col_width: ['50px', '150px', '100px', '100px'],
        extensions: {
            name: ['ColsVisibility'],
            src: ['/javascripts/tableFilter/TFExt_ColsVisibility/TFExt_ColsVisibility.js'],
            description: ['Columns visibility manager'],
            initialize: [function(o){
                o.SetColsVisibility();
            }
]
        },
        sort_config: {
            sort_types: sort_cols,
            sort_col: [initial_column, false]
        },
        help_instructions_text: "Use the filters above each column to filter and limit table data. Type your text and press Enter.\n Each column can be sorted too."
    };
    for (key in cols) {
        props[key] = cols[key];
    }
    return setFilterGrid(tableName, props);
}


function setSchoolTable(){
    columnSize = 4;
    var cols = {
        col_2: "select"
    };
    tf = setTableFilter("filterTable", cols, [], 1, false);
}

function setTable(columnSize, defaultColumns){
    var cols = {
        col_0: "none",
        col_3: "select"
    };
    for (var i = columnSize - 1; i > defaultColumns - 1 ; i--) {
        cols["col_" + i] = "none";
    };
    
	
    var sort_cols = ['None'];
	for (var i = 1; i < defaultColumns; i++) {
        sort_cols.push('String');
    };
    for (var i = columnSize - 1; i > defaultColumns - 1; i--) {
        sort_cols.push('None');
    };
    tf = setTableFilter("filterTable", cols, sort_cols, 1, true);
}

function tableToCSV(tableID){
    jQuery("#" + tableID).table2CSV();
}
