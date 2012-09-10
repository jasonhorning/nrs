// create our editable grid
var editableGrid = new EditableGrid("RegistryColumnsGrid", {enableSort: false, editmode: "absolute"});

// helper function to get path of a demo image
function image(relativePath) {
	return "images/" + relativePath;
}

// this function will initialize our editable grid
EditableGrid.prototype.initializeGrid = function()
{
	with (this) {

		// use autocomplete for Registry Column Name
		setCellEditor("Column Name", new AutocompleteCellEditor({
			suggestions: ['Value','Description','References','Date']
		}));

		// render for the action column (this code is modified from the demo)
		setCellRenderer("action", new CellRenderer({render: function(cell, value) {
			// the delete action will remove the row, so first find the ID of the row containing this cell
			var rowId = editableGrid.getRowId(cell.rowIndex);

			cell.innerHTML = "<a onclick=\"if (confirm('Are you sure you want to delete this registry column? ')) { editableGrid.remove(" + cell.rowIndex + "); } \" style=\"cursor:pointer\">" +
							 "<img src=\"" + image("delete.png") + "\" border=\"0\" alt=\"delete\" title=\"Delete registry column\"/></a>";

			cell.innerHTML+= "&nbsp;<a onclick=\"editableGrid.duplicate(" + cell.rowIndex + ");\" style=\"cursor:pointer\">" +
			 "<img src=\"" + image("duplicate.png") + "\" border=\"0\" alt=\"duplicate\" title=\"Duplicate registry column\"/></a>";

		}}));
    }
};

EditableGrid.prototype.duplicate = function(rowIndex)
{
	// copy values from given row
	var values = this.getRowValues(rowIndex);
	values['name'] = values['name'] + ' (copy)';

	// get id for new row (max id + 1)
	var newRowId = 0;
	for (var r = 0; r < this.getRowCount(); r++) newRowId = Math.max(newRowId, parseInt(this.getRowId(r)) + 1);

	// add new row
	this.insertAfter(rowIndex, newRowId, values);
};

