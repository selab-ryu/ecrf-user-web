package ecrf.user.teeth.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;

import java.util.ArrayList;
import java.util.List;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.teeth.constants.ECRFTeethPortletKeys;
import teeth.model.TreatmentHistory;
import teeth.service.TreatmentHistoryLocalServiceUtil;


@Component(
       immediate = true,
       property = {
           "javax.portlet.name=" + ECRFTeethPortletKeys.ECRFTEETH,
           "mvc.command.name=/teeth/editHistoryPopup"
       },
       service = MVCRenderCommand.class
   )
public class EditPopupRenderCommand implements MVCRenderCommand {

   @Override
   public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
      String TreatmentIDList = ParamUtil.getString(renderRequest, "TreatmentID");
      _log.info("Received TreatmentIDList: " + TreatmentIDList);
      
      List<TreatmentHistory> EditHistoryList = new ArrayList<>(); 
      List<Long> IDList = new ArrayList<>(); // list for parsed ids
      
      // parse ids from TreatmentIDList
      if (TreatmentIDList != null && !TreatmentIDList.isEmpty()) {
          // 쉼표로 분리
          String[] tokens = TreatmentIDList.split(",");
          for (String token : tokens) {
        	  
              // trim for blank remove
              token = token.trim();
              if (!token.isEmpty()) {
                  // string to long (type cast)
                  IDList.add(Long.parseLong(token));
              }
          }
      }
      _log.info("Parsed IDList: " + IDList);
      
      // retrieve treatement by parsed id
      for (Long ID : IDList)
      {
         try {
            TreatmentHistory TH = TreatmentHistoryLocalServiceUtil.getPatientTreatmentByTreatmentID(ID);
            EditHistoryList.add(TH);
         } catch(Exception e)
         {
            _log.info("Error During making List; ID: " + ID);
            e.printStackTrace();
         }
      }
      
      _log.info("Completed EditHistory List: " + EditHistoryList);
      
      renderRequest.setAttribute("EditHistoryList", EditHistoryList); //TreatmentHistory List
      
      
      return "/teeth/edit/editHistoryPopup.jsp";
   }
   Log _log = LogFactoryUtil.getLog(EditPopupRenderCommand.class);
}
