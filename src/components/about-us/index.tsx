"use client";

import React from "react";
import { Button } from "../ui/button";
import Image from "next/image";
import Link from "next/link";
import FounderQuote from "./FounderQuote";
import MeetTheBrains from "./MeetTheBrains";
import ViteezyTimeline from "./ViteezyTimeline";
import TeamMembers from "./TeamMembers";
import { useGetAboutUsQuery } from "@/store/api/aboutUsApi";

const AboutUsPage = () => {
  const { data, isLoading } = useGetAboutUsQuery();
  const aboutUs = data?.data?.aboutUs;

  if (isLoading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-teal-500"></div>
      </div>
    );
  }

  if (!aboutUs) {
    return null;
  }

  const {
    banner,
    founderNote,
    founderStory,
    meetBrains,
    timeline,
    people,
    theStory,
  } = aboutUs;

  return (
    <div className="w-full">
      {/* Banner Section */}
      <div className="w-full py-8 sm:py-14">
        <div className="w-section mx-auto w-full px-4 sm:px-6 lg:px-8">
          <h1 className="text-4xl sm:text-5xl md:text-6xl sm:max-w-xl font-medium mb-5">
            {banner?.banner_title}
          </h1>
          <div className="flex items-start md:items-end flex-col md:flex-row md:justify-between gap-5 md:gap-10">
            <p className="max-w-3xl text-base sm:text-lg leading-tight">
              {banner?.banner_description}
            </p>
            {banner?.banner_button_text && (
              <Link href={banner.banner_button_link || "#"}>
                <Button variant="elevate" size="elevate" animateText>
                  {banner.banner_button_text}
                </Button>
              </Link>
            )}
          </div>
        </div>
        <div className="px-4 sm:px-3 overflow-hidden rounded-2xl">
          {banner?.banner_image?.url && (
            <Image
              src={banner.banner_image.url}
              alt="About Us Banner"
              className="w-full mt-7 sm:mt-14 object-cover min-h-[230px] max-h-[550px] rounded-[28px]"
              width={1920}
              height={550}
            />
          )}
        </div>
      </div>

      {/* Founder Quote/Story Section */}
      {founderStory && (
        <FounderQuote
          quote={founderNote.headline}
          quoteDescription={founderNote.description}
          author={founderStory.name}
          authorRole={founderStory.position}
          authorImage={founderStory.image?.url || ""}
          noteTitle={founderStory.headline}
          noteContent={
            founderStory.description ? [founderStory.description] : []
          }
        />
      )}

      {/* Meet the Brains Section */}
      {meetBrains && (
        <MeetTheBrains
          title={meetBrains.meet_brains_title}
          description={meetBrains.meet_brains_subtitle}
          footnote=""
          teamImage={meetBrains.meet_brains_main_image?.url || ""}
          teamImageAlt="Team members working together"
        />
      )}

      {/* Timeline Section */}
      {timeline && (
        <ViteezyTimeline
          title={timeline.timeline_section_title}
          subtitle={timeline.timeline_section_description}
          entries={timeline.timeline_events.map((event: any) => ({
            date: event.year,
            title: event.title,
            description: event.description,
            isActive: true,
          }))}
        />
      )}

      {/* Team Members Section */}
      {people && (
        <TeamMembers
          title={people.title}
          description={people.subtitle}
          buttonText="Our Team"
          buttonLink="/ourTeam"
          members={people.images.map((img: any, index: number) => ({
            id: String(index),
            name: "",
            image: img.url,
            imageAlt: `Team member ${index + 1}`,
          }))}
        />
      )}
    </div>
  );
};

export default AboutUsPage;
