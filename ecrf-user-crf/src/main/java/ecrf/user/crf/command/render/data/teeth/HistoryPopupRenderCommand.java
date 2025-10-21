package ecrf.user.crf.command.render.data.teeth;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Comparator;
import java.util.Date;
import java.util.List;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.crf.util.data.DisplayHistory;
import ecrf.user.model.Subject;
import ecrf.user.service.SubjectLocalService;
import teeth.model.TreatmentHistory;
import teeth.service.TreatmentHistoryLocalService;
import teeth.service.TreatmentHistoryLocalServiceUtil;


@Component(
	immediate = true,
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
		"mvc.command.name=/teeth/historyPopup"
	},
	service = MVCRenderCommand.class
)
public class HistoryPopupRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("Render History!");
		String regionName = ParamUtil.getString(renderRequest, "regionName");
		_log.info("regionName: " + regionName);
		long teethNum = Long.parseLong(regionName.replace("Teeth", ""));
		_log.info("teethNum:" + teethNum);

		ThemeDisplay themeDisplay = (ThemeDisplay)renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
		long groupId = themeDisplay.getScopeGroupId();
		
		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long linkId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.LINK_ID, 0);
		
		_log.info(groupId + " / " + crfId + " / " + subjectId + " / " + linkId);
		
		List<TreatmentHistory> treatmenthistory = _treatmentHistoryLocalService.getTreatmentsByG_C_P_L_TN(groupId, crfId, subjectId, linkId, teethNum);
		_log.info("List: " + treatmenthistory);

		// Date Formatter for birth
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		Date birth = null;

		Subject subject = null;
		if(subjectId > 0) {
			try {
				subject = _subjectLocalService.getSubject(subjectId);
				birth = subject.getBirth();
			} catch (Exception e) {
				e.printStackTrace();
				
				try {
					birth = sdf.parse("2023-01-01");
				} catch(ParseException pe) {
					pe.printStackTrace();
					birth = new Date();
				}
			}
		}

		List<DisplayHistory> displayList = DisplayHistory.buildDisplayHistoryList(treatmenthistory, birth);

		for(DisplayHistory dh : displayList)
		{
			if(dh.Status.isEmpty())
			{
				dh.setStatus("-");
			}
			if(dh.TreatmnetString.isEmpty())
			{
				dh.setTreatmnetString("-");
			}
		}

		displayList.sort(Comparator.comparing(DisplayHistory::getDate).reversed());
		_log.info("DisplayList: " + displayList);

		renderRequest.setAttribute("teethNum", teethNum);
		renderRequest.setAttribute("displayList", displayList);
		renderRequest.setAttribute("regionName", regionName);
		
		return "/html/crf-data/teeth/history-popup.jsp";
	}

	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private TreatmentHistoryLocalService _treatmentHistoryLocalService;

	Log _log = LogFactoryUtil.getLog(HistoryPopupRenderCommand.class);

}
