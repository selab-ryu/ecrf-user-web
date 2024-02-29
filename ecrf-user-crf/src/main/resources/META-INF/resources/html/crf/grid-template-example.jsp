<style>

.grid-row {
	width:100%;
	display:grid;
	grid-template-columns:50px 50px auto auto 100px;
}

.grid-row>div>input {
	width:100%;
}

</style>

<div>
	<aui:container cssClass="radius-shadow-container">
		<aui:row>
			<aui:col>
				<aui:button name="gridUpdate" value="Grid Update" />
			</aui:col>
		</aui:row>
		
		<aui:row>
			<div id="rowGrid2" class="grid-row" style="grid-template-columns:auto auto auto;">
				<div><input name="heigth1" label="heigth-1"/></div>
				<div><input name="heigth2" label="heigth-2"/></div>
				<div><input name="heigth3" label="heigth-3"/></div>
				<div><input name="heigth4" label="heigth-4"/></div>
				<div><input name="heigth5" label="heigth-5"/></div>
			</div>
		</aui:row>
		
		<aui:row>
			<div id="rowGrid" class="grid-row">
				<div><input type="number" maxlength="3" name="pulse1" label="pulse-1"/></div>
				<div><input name="pulse2" label="pulse-2"/></div>
				<div><input name="pulse3" label="pulse-3"/></div>
				<div><input name="pulse4" label="pulse-4"/></div>
				<div><input name="pulse5" label="pulse-5"/></div>
			</div>
		</aui:row>
		
		<aui:row>
			<aui:col md="12" cssClass="sub-title-bottom-border marBr">
				<span class="sub-title-span">
					<liferay-ui:message key="ecrf-user.crf.title.crf-info" />
				</span>
			</aui:col>
		</aui:row>
	</aui:container>
</div>