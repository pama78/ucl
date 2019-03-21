package cz.unicorncollege.bt.model;

import java.util.ArrayList;
import java.util.List;


public class MeetingCentre extends MeetingObject {
	private List<MeetingRoom> meetingRooms;

	public List<MeetingRoom> getMeetingRooms() {
		return meetingRooms;
	}

	public void setMeetingRooms(List<MeetingRoom> meetingRooms) {
		this.meetingRooms = meetingRooms;
	}

	public void addMC(MeetingRoom meetingRoom) {
		if (meetingRooms == null) {
			meetingRooms = new ArrayList<>();
		}
		this.meetingRooms.add(meetingRoom);

	}

}
